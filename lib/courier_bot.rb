require 'ostruct'

require 'active_support'
require 'active_support/core_ext'
require 'mustermann'
require 'slack'
require 'sucker_punch'
require 'sinatra/base'

require 'courier_bot/app'
require 'courier_bot/bot'
require 'courier_bot/contexts/bot'
require 'courier_bot/contexts/task'
require 'courier_bot/contexts/timer'
require 'courier_bot/slack_http_request'
require 'courier_bot/version'

module CourierBot
  def self.load
    configure!

    Bot.new.tap do |bot|
      identify! bot
      load_scripts! bot

      App.set :bot, bot

      yield App
    end
  end

  class << self
    private

    def configure!
      Slack.configure do |config|
        config.token = ENV.fetch('SLACK_ACCESS_TOKEN')
      end

      Slack::Events.configure do |config|
        config.signing_secret = ENV.fetch('SLACK_SIGNING_SECRET')
        config.signature_expires_in = 300
      end
    rescue KeyError => error
      warn <<-MSG
You have not setup your environment variables correctly. Please define:
  - SLACK_ACCESS_TOKEN using the "Tokens for Your Workspace" found on Slack's
    "OAuth & Permissions" of for your Slack application.
  - SLACK_SIGNING_SECRET using the "Signing Secret" found on the "App
    Credentials" section under "Basic Information"
      MSG

      exit 1
    end

    def identify!(bot)
      bot.identify!
    rescue Slack::Web::Api::Errors::SlackError => slack_error
      p slack_error
      warn <<-MSG
The slack auth test failed. This could likely be due to an incorrect or expired
SLACK_ACCESS_TOKEN. Please double check your configuration and try again.
      MSG

      exit 1
    end

    def load_scripts!(bot)
      task_files = Dir[File.join(Dir.pwd, '**', '*.cb.rb')]

      if task_files.empty?
        warn <<-MSG
No task files were detected. courier_bot will scan the working directory for
files that end with ".cb.rb" extension and will automatically evaluate these
files within the bot's DSL context.

To prevent this warning, please add at least one courier_bot task file.
        MSG

        exit 1
      end

      task_files.each do |script_file|
        obj = Contexts::Bot.new(bot, script_file)
        obj.evaluate
      end
    end
  end
end

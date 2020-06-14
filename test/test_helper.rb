$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "courier_bot"

require "minitest/autorun"
require 'rack/test'
require 'sucker_punch/testing/inline'

class Minitest::Test
  def self.test(name, &block)
    define_method "test_#{name.gsub(/\s+/, '_')}", &block
  end

  def self.setup(&block)
    define_method :setup, &block
  end

  def self.teardown(&block)
    define_method :teardown, &block
  end
end

class AppTestCase < Minitest::Test
  include Rack::Test::Methods

  setup do
    Slack.configure do |config|
      config.token = 'test_token'
    end

    Slack::Events.configure do |config|
      config.signing_secret = 'test_signing_secret'
      config.signature_expires_in = 300
    end
  end

  def app
    CourierBot::App
  end

  def post_event(payload, signing_secret: 'test_signing_secret', version: 'v0')
    body = JSON.dump(payload)
    timestamp = Time.now.to_i
    digest = OpenSSL::Digest::SHA256.new

    signature_basestring = [version, timestamp, body].join(':')
    hex_hash = OpenSSL::HMAC.hexdigest(digest, signing_secret, signature_basestring)

    signature = [version, hex_hash].join('=')

    post '/events', body, {
      'HTTP_X_SLACK_SIGNATURE' => signature,
      'HTTP_X_SLACK_REQUEST_TIMESTAMP' => timestamp,
    }
  end
end

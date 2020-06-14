module CourierBot
  class App < Sinatra::Base
    helpers do
      def slack_request
        @slack_request ||= Slack::Events::Request.new(SlackHttpRequest.convert(request))
      end

      def slack_payload
        @slack_payload ||= JSON.parse(slack_request.body, symbolize_names: true)
      end
    end

    before '/events' do
      begin
        slack_request.verify!
      rescue => error
        warn error

        halt 400, 'Invalid request'
      end
    end

    post '/events' do
      case slack_payload[:type]
      when 'url_verification'
        content_type 'text/plain'

        status 200

        slack_payload.fetch(:challenge)
      when 'event_callback'
        settings.bot.dispatch slack_payload[:event]

        status 200
      else
        puts "Unknown event type: #{slack_payload[:type]}"
        puts slack_payload.inspect

        status 404
      end
    end
  end
end

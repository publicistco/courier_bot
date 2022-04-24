module CourierBot
  module Contexts
    class Timer
      include Contexts::Shared

      def initialize(slack_client, on:)
        @slack_client = slack_client
        @slack_channel = on
      end

      def evaluate(&block)
        instance_eval(&block)
      end

      private

      attr_reader :slack_channel, :slack_client

      def post_message_to_channel(message)
        slack_client.chat_postMessage(
          channel: slack_channel,
          text: message,
          as_user: true
        )
      end
    end
  end
end

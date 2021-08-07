module CourierBot
  module Contexts
    class Task
      def initialize(params, event_text, event_payload)
        @params = params
        @event_text = event_text
        @event_payload = event_payload
      end

      def evaluate(&block)
        instance_eval(&block)
      end

      private

      attr_reader :event_text, :event_payload

      def slack_channel
        @event_payload[:channel]
      end

      def slack_thread_ts
        @event_payload[:ts]
      end

      def post_message_to_channel(message)
        slack_client.chat_postMessage(
          channel: slack_channel,
          text: message,
          as_user: true
        )
      end

      def post_message_to_thread(message)
        slack_client.chat_postMessage(
          channel: slack_channel,
          thread_ts: slack_thread_ts,
          text: message,
          as_user: true
        )
      end
    end
  end
end

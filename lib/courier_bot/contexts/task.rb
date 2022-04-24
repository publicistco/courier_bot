module CourierBot
  module Contexts
    class Task
      include Contexts::Shared

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
    end
  end
end

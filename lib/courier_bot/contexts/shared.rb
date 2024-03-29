module CourierBot
  module Contexts
    module Shared
      private

      def config_value(name)
        ENV.fetch("COURIER_BOT_#{name.to_s.upcase}")
      end

      def slack_channel
        raise NotImplementedError
      end

      def slack_thread_ts
        raise NotImplementedError
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

      def upload_file_to_channel(io, content_type:, filename:, **kwargs)
        slack_client.files_upload(
          channels: slack_channel,
          file: Faraday::UploadIO.new(io, content_type),
          filename: filename,
          as_user: true,
          **kwargs
        )
      end
    end
  end
end

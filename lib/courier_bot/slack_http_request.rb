module CourierBot
  class SlackHttpRequest < Struct.new(:body, :headers)
    def self.convert(request)
      new request.body, {
        'X-Slack-Signature' => request.env['HTTP_X_SLACK_SIGNATURE'],
        'X-Slack-Request-Timestamp' => request.env['HTTP_X_SLACK_REQUEST_TIMESTAMP']
      }
    end
  end
end

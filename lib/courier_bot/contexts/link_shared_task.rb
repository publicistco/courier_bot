module CourierBot
  module Contexts
    class LinkSharedTask < Task
      include Contexts::Shared

      attr_reader :url, :domain

      def initialize(domain, url, event_payload)
        @domain = domain
        @url = url
        @event_payload = event_payload
      end

      def self.expand_event(event)
        event[:links].each do |link|
          yield link[:domain], link[:url]
        end
      end
    end
  end
end

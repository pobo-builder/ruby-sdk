# frozen_string_literal: true

module Pobo
  module DTO
    class WebhookPayload
      attr_reader :event, :timestamp, :eshop_id

      def initialize(event:, timestamp:, eshop_id:)
        @event = event
        @timestamp = timestamp
        @eshop_id = eshop_id
      end

      def self.from_hash(hash)
        timestamp = hash["timestamp"] || hash[:timestamp]
        timestamp = Time.at(timestamp) if timestamp.is_a?(Integer)
        timestamp = Time.parse(timestamp) if timestamp.is_a?(String)

        new(
          event: hash["event"] || hash[:event],
          timestamp: timestamp,
          eshop_id: hash["eshop_id"] || hash[:eshop_id]
        )
      end
    end
  end
end

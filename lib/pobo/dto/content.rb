# frozen_string_literal: true

module Pobo
  module DTO
    class Content
      attr_reader :html, :marketplace

      def initialize(html: {}, marketplace: {})
        @html = html.transform_keys(&:to_s)
        @marketplace = marketplace.transform_keys(&:to_s)
      end

      def self.from_hash(hash)
        return nil if hash.nil?

        new(
          html: hash["html"] || hash[:html] || {},
          marketplace: hash["marketplace"] || hash[:marketplace] || {}
        )
      end

      def get_html(language)
        @html[language.to_s]
      end

      def get_marketplace(language)
        @marketplace[language.to_s]
      end

      def html_default
        @html["default"]
      end

      def marketplace_default
        @marketplace["default"]
      end

      def to_hash
        {
          "html" => @html,
          "marketplace" => @marketplace
        }
      end

      alias to_h to_hash
    end
  end
end

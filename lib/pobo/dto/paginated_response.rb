# frozen_string_literal: true

module Pobo
  module DTO
    class PaginatedResponse
      attr_reader :data, :current_page, :per_page, :total

      def initialize(data:, current_page:, per_page:, total:)
        @data = data
        @current_page = current_page
        @per_page = per_page
        @total = total
      end

      def self.from_hash(hash, item_class)
        items = (hash["data"] || hash[:data] || []).map do |item|
          item_class.from_hash(item)
        end

        meta = hash["meta"] || hash[:meta] || {}

        new(
          data: items,
          current_page: meta["current_page"] || meta[:current_page] || 1,
          per_page: meta["per_page"] || meta[:per_page] || 100,
          total: meta["total"] || meta[:total] || 0
        )
      end

      def total_pages
        return 0 if @per_page.zero?

        (@total.to_f / @per_page).ceil
      end

      def more_pages?
        @current_page < total_pages
      end

      alias has_more_pages? more_pages?
    end
  end
end

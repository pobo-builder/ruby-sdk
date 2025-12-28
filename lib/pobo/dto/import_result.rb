# frozen_string_literal: true

module Pobo
  module DTO
    class ImportResult
      attr_reader :success, :imported, :updated, :skipped, :errors,
                  :values_imported, :values_updated

      def initialize(
        success:,
        imported: 0,
        updated: 0,
        skipped: 0,
        errors: [],
        values_imported: nil,
        values_updated: nil
      )
        @success = success
        @imported = imported
        @updated = updated
        @skipped = skipped
        @errors = errors
        @values_imported = values_imported
        @values_updated = values_updated
      end

      def self.from_hash(hash)
        new(
          success: hash["success"] || hash[:success] || true,
          imported: hash["imported"] || hash[:imported] || 0,
          updated: hash["updated"] || hash[:updated] || 0,
          skipped: hash["skipped"] || hash[:skipped] || 0,
          errors: hash["errors"] || hash[:errors] || [],
          values_imported: hash["values_imported"] || hash[:values_imported],
          values_updated: hash["values_updated"] || hash[:values_updated]
        )
      end

      def errors?
        !@errors.empty?
      end

      alias has_errors? errors?
    end
  end
end

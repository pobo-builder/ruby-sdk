# frozen_string_literal: true

module Pobo
  module DTO
    class ParameterValue
      attr_reader :id, :value

      def initialize(id:, value:)
        @id = id
        @value = value
      end

      def self.from_hash(hash)
        new(
          id: hash["id"] || hash[:id],
          value: hash["value"] || hash[:value]
        )
      end

      def to_hash
        {
          "id" => @id,
          "value" => @value
        }
      end

      alias to_h to_hash
    end

    class Parameter
      attr_reader :id, :name, :values

      def initialize(id:, name:, values: [])
        @id = id
        @name = name
        @values = values
      end

      def self.from_hash(hash)
        values = (hash["values"] || hash[:values] || []).map do |v|
          ParameterValue.from_hash(v)
        end

        new(
          id: hash["id"] || hash[:id],
          name: hash["name"] || hash[:name],
          values: values
        )
      end

      def to_hash
        {
          "id" => @id,
          "name" => @name,
          "values" => @values.map(&:to_hash)
        }
      end

      alias to_h to_hash
    end
  end
end

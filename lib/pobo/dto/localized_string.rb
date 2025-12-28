# frozen_string_literal: true

module Pobo
  module DTO
    class LocalizedString
      attr_reader :translations

      def initialize(default_value = nil, translations: {})
        @translations = translations.transform_keys(&:to_s)
        @translations["default"] = default_value if default_value
      end

      def self.create(default_value)
        new(default_value)
      end

      def self.from_hash(hash)
        return nil if hash.nil?

        instance = new
        hash.each do |key, value|
          instance.translations[key.to_s] = value
        end
        instance
      end

      def with_translation(language, value)
        new_translations = @translations.dup
        new_translations[language.to_s] = value
        self.class.new(nil, translations: new_translations)
      end

      def default
        @translations["default"]
      end

      def get(language)
        @translations[language.to_s]
      end

      def to_hash
        @translations.dup
      end

      alias to_h to_hash
    end
  end
end

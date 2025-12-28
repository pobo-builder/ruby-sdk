# frozen_string_literal: true

module Pobo
  module DTO
    class Blog
      attr_reader :id, :is_visible, :name, :url, :category, :description,
                  :seo_title, :seo_description, :content, :images, :is_loaded,
                  :created_at, :updated_at

      def initialize(
        id:,
        is_visible:,
        name:,
        url:,
        category: nil,
        description: nil,
        seo_title: nil,
        seo_description: nil,
        content: nil,
        images: [],
        is_loaded: nil,
        created_at: nil,
        updated_at: nil
      )
        @id = id
        @is_visible = is_visible
        @name = name
        @url = url
        @category = category
        @description = description
        @seo_title = seo_title
        @seo_description = seo_description
        @content = content
        @images = images
        @is_loaded = is_loaded
        @created_at = created_at
        @updated_at = updated_at
      end

      def self.from_hash(hash)
        new(
          id: hash["id"] || hash[:id],
          is_visible: hash.key?("is_visible") ? hash["is_visible"] : hash[:is_visible],
          name: LocalizedString.from_hash(hash["name"] || hash[:name]),
          url: LocalizedString.from_hash(hash["url"] || hash[:url]),
          category: hash["category"] || hash[:category],
          description: LocalizedString.from_hash(hash["description"] || hash[:description]),
          seo_title: LocalizedString.from_hash(hash["seo_title"] || hash[:seo_title]),
          seo_description: LocalizedString.from_hash(hash["seo_description"] || hash[:seo_description]),
          content: Content.from_hash(hash["content"] || hash[:content]),
          images: hash["images"] || hash[:images] || [],
          is_loaded: hash.key?("is_loaded") ? hash["is_loaded"] : hash[:is_loaded],
          created_at: parse_time(hash["created_at"] || hash[:created_at]),
          updated_at: parse_time(hash["updated_at"] || hash[:updated_at])
        )
      end

      def to_hash
        data = {
          "id" => @id,
          "is_visible" => @is_visible,
          "name" => @name&.to_hash,
          "url" => @url&.to_hash
        }

        data["category"] = @category if @category
        data["description"] = @description.to_hash if @description
        data["seo_title"] = @seo_title.to_hash if @seo_title
        data["seo_description"] = @seo_description.to_hash if @seo_description
        data["images"] = @images unless @images.empty?

        data
      end

      alias to_h to_hash

      private

      def self.parse_time(value)
        return nil if value.nil?
        return value if value.is_a?(Time)

        Time.parse(value)
      rescue ArgumentError
        nil
      end
    end
  end
end

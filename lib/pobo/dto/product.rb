# frozen_string_literal: true

module Pobo
  module DTO
    class Product
      attr_reader :id, :is_visible, :name, :url, :short_description, :description,
                  :seo_title, :seo_description, :content, :images, :categories_ids,
                  :parameters_ids, :guid, :is_loaded, :categories, :created_at, :updated_at

      def initialize(
        id:,
        is_visible:,
        name:,
        url:,
        short_description: nil,
        description: nil,
        seo_title: nil,
        seo_description: nil,
        content: nil,
        images: [],
        categories_ids: [],
        parameters_ids: [],
        guid: nil,
        is_loaded: nil,
        categories: [],
        created_at: nil,
        updated_at: nil
      )
        @id = id
        @is_visible = is_visible
        @name = name
        @url = url
        @short_description = short_description
        @description = description
        @seo_title = seo_title
        @seo_description = seo_description
        @content = content
        @images = images
        @categories_ids = categories_ids
        @parameters_ids = parameters_ids
        @guid = guid
        @is_loaded = is_loaded
        @categories = categories
        @created_at = created_at
        @updated_at = updated_at
      end

      def self.from_hash(hash)
        new(
          id: hash["id"] || hash[:id],
          is_visible: hash["is_visible"] || hash[:is_visible],
          name: LocalizedString.from_hash(hash["name"] || hash[:name]),
          url: LocalizedString.from_hash(hash["url"] || hash[:url]),
          short_description: LocalizedString.from_hash(hash["short_description"] || hash[:short_description]),
          description: LocalizedString.from_hash(hash["description"] || hash[:description]),
          seo_title: LocalizedString.from_hash(hash["seo_title"] || hash[:seo_title]),
          seo_description: LocalizedString.from_hash(hash["seo_description"] || hash[:seo_description]),
          content: Content.from_hash(hash["content"] || hash[:content]),
          images: hash["images"] || hash[:images] || [],
          categories_ids: hash["categories_ids"] || hash[:categories_ids] || [],
          parameters_ids: hash["parameters_ids"] || hash[:parameters_ids] || [],
          guid: hash["guid"] || hash[:guid],
          is_loaded: hash["is_loaded"] || hash[:is_loaded],
          categories: hash["categories"] || hash[:categories] || [],
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

        data["short_description"] = @short_description.to_hash if @short_description
        data["description"] = @description.to_hash if @description
        data["seo_title"] = @seo_title.to_hash if @seo_title
        data["seo_description"] = @seo_description.to_hash if @seo_description
        data["images"] = @images unless @images.empty?
        data["categories_ids"] = @categories_ids unless @categories_ids.empty?
        data["parameters_ids"] = @parameters_ids unless @parameters_ids.empty?

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

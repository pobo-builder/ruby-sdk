# frozen_string_literal: true

module Pobo
  module WebhookEvent
    PRODUCTS_UPDATE = "products.update"
    CATEGORIES_UPDATE = "categories.update"
    BLOGS_UPDATE = "blogs.update"

    ALL = [PRODUCTS_UPDATE, CATEGORIES_UPDATE, BLOGS_UPDATE].freeze

    def self.valid?(event)
      ALL.include?(event)
    end
  end
end

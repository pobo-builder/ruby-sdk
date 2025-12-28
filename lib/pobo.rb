# frozen_string_literal: true

require_relative "pobo/version"
require_relative "pobo/errors"

require_relative "pobo/enum/language"
require_relative "pobo/enum/webhook_event"

require_relative "pobo/dto/localized_string"
require_relative "pobo/dto/content"
require_relative "pobo/dto/product"
require_relative "pobo/dto/category"
require_relative "pobo/dto/blog"
require_relative "pobo/dto/parameter"
require_relative "pobo/dto/import_result"
require_relative "pobo/dto/paginated_response"
require_relative "pobo/dto/webhook_payload"

require_relative "pobo/client"
require_relative "pobo/webhook_handler"

module Pobo
  class << self
    # Convenience method to create a client
    def client(api_token:, base_url: Client::DEFAULT_BASE_URL, timeout: Client::DEFAULT_TIMEOUT)
      Client.new(api_token: api_token, base_url: base_url, timeout: timeout)
    end

    # Convenience method to create a webhook handler
    def webhook_handler(webhook_secret:)
      WebhookHandler.new(webhook_secret: webhook_secret)
    end
  end
end

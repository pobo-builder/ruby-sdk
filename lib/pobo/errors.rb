# frozen_string_literal: true

module Pobo
  class Error < StandardError; end

  class ApiError < Error
    attr_reader :http_code, :response_body

    def initialize(message, http_code: nil, response_body: nil)
      @http_code = http_code
      @response_body = response_body
      super(message)
    end

    def self.unauthorized
      new("Authorization token required", http_code: 401)
    end

    def self.from_response(http_code, body)
      message = body.is_a?(Hash) ? (body["error"] || body["message"] || "API error") : "API error"
      new(message, http_code: http_code, response_body: body)
    end
  end

  class ValidationError < Error
    attr_reader :errors

    def initialize(message, errors: {})
      @errors = errors
      super(message)
    end

    def self.empty_payload
      new("Payload cannot be empty")
    end

    def self.too_many_items(count, max)
      new("Too many items: #{count} provided, maximum is #{max}")
    end
  end

  class WebhookError < Error
    def self.missing_signature
      new("Missing webhook signature")
    end

    def self.invalid_signature
      new("Invalid webhook signature")
    end

    def self.invalid_payload
      new("Invalid webhook payload")
    end
  end
end

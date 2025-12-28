# frozen_string_literal: true

require "openssl"
require "json"

module Pobo
  class WebhookHandler
    SIGNATURE_HEADER = "X-Webhook-Signature"

    def initialize(webhook_secret:)
      @webhook_secret = webhook_secret
    end

    # Handle webhook from Rack request
    def handle_request(request)
      payload = request.body.read
      request.body.rewind if request.body.respond_to?(:rewind)

      signature = request.env["HTTP_X_WEBHOOK_SIGNATURE"] ||
                  request.get_header("HTTP_X_WEBHOOK_SIGNATURE") rescue nil

      handle(payload: payload, signature: signature)
    end

    # Handle webhook with raw payload and signature
    def handle(payload:, signature:)
      raise WebhookError.missing_signature if signature.nil? || signature.empty?
      raise WebhookError.invalid_signature unless valid_signature?(payload, signature)

      data = JSON.parse(payload)
      DTO::WebhookPayload.from_hash(data)
    rescue JSON::ParserError
      raise WebhookError.invalid_payload
    end

    private

    def valid_signature?(payload, signature)
      expected = OpenSSL::HMAC.hexdigest("SHA256", @webhook_secret, payload)
      secure_compare(expected, signature)
    end

    def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      OpenSSL.fixed_length_secure_compare(a, b)
    rescue NoMethodError
      # Fallback for older Ruby versions
      a == b
    end
  end
end

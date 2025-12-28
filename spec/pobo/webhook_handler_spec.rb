# frozen_string_literal: true

require "spec_helper"
require "openssl"

RSpec.describe Pobo::WebhookHandler do
  let(:secret) { "webhook-secret" }
  let(:handler) { described_class.new(webhook_secret: secret) }

  def sign(payload)
    OpenSSL::HMAC.hexdigest("SHA256", secret, payload)
  end

  describe "#handle" do
    it "validates and parses webhook payload" do
      payload = { event: "products.update", timestamp: 1704067200, eshop_id: 123 }.to_json
      signature = sign(payload)

      result = handler.handle(payload: payload, signature: signature)

      expect(result.event).to eq("products.update")
      expect(result.eshop_id).to eq(123)
      expect(result.timestamp).to be_a(Time)
    end

    it "raises error for missing signature" do
      payload = { event: "products.update" }.to_json

      expect { handler.handle(payload: payload, signature: nil) }
        .to raise_error(Pobo::WebhookError, "Missing webhook signature")
    end

    it "raises error for invalid signature" do
      payload = { event: "products.update" }.to_json

      expect { handler.handle(payload: payload, signature: "invalid") }
        .to raise_error(Pobo::WebhookError, "Invalid webhook signature")
    end

    it "raises error for invalid JSON" do
      payload = "not json"
      signature = sign(payload)

      expect { handler.handle(payload: payload, signature: signature) }
        .to raise_error(Pobo::WebhookError, "Invalid webhook payload")
    end
  end
end

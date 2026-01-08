# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pobo::WebhookEvent do
  describe "constants" do
    it "defines PRODUCTS_UPDATE" do
      expect(described_class::PRODUCTS_UPDATE).to eq("products.update")
    end

    it "defines CATEGORIES_UPDATE" do
      expect(described_class::CATEGORIES_UPDATE).to eq("categories.update")
    end

    it "defines BLOGS_UPDATE" do
      expect(described_class::BLOGS_UPDATE).to eq("blogs.update")
    end

    it "includes all events in ALL" do
      expect(described_class::ALL).to contain_exactly(
        "products.update",
        "categories.update",
        "blogs.update"
      )
    end
  end

  describe ".valid?" do
    it "returns true for valid events" do
      expect(described_class.valid?("products.update")).to be true
      expect(described_class.valid?("categories.update")).to be true
      expect(described_class.valid?("blogs.update")).to be true
    end

    it "returns false for invalid events" do
      expect(described_class.valid?("invalid.event")).to be false
      expect(described_class.valid?("")).to be false
      expect(described_class.valid?(nil)).to be false
    end
  end
end

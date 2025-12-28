# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pobo::Client do
  let(:client) { described_class.new(api_token: "test-token") }

  describe "#import_products" do
    it "sends products to API" do
      stub_request(:post, "https://api.pobo.space/api/v2/rest/products")
        .with(
          headers: { "Authorization" => "Bearer test-token" },
          body: [{ "id" => "PROD-001", "is_visible" => true, "name" => { "default" => "Product" }, "url" => { "default" => "https://example.com" } }]
        )
        .to_return(
          status: 200,
          body: { success: true, imported: 1, updated: 0, skipped: 0, errors: [] }.to_json
        )

      product = Pobo::DTO::Product.new(
        id: "PROD-001",
        is_visible: true,
        name: Pobo::DTO::LocalizedString.create("Product"),
        url: Pobo::DTO::LocalizedString.create("https://example.com")
      )

      result = client.import_products([product])

      expect(result.success).to be true
      expect(result.imported).to eq(1)
    end

    it "raises error for empty payload" do
      expect { client.import_products([]) }.to raise_error(Pobo::ValidationError, "Payload cannot be empty")
    end

    it "raises error for too many items" do
      products = 101.times.map do |i|
        { id: "PROD-#{i}", is_visible: true, name: { default: "Product #{i}" }, url: { default: "https://example.com" } }
      end

      expect { client.import_products(products) }.to raise_error(Pobo::ValidationError, /Too many items/)
    end
  end

  describe "#get_products" do
    it "fetches paginated products" do
      stub_request(:get, "https://api.pobo.space/api/v2/rest/products?page=1&per_page=50")
        .with(headers: { "Authorization" => "Bearer test-token" })
        .to_return(
          status: 200,
          body: {
            data: [
              { id: "PROD-001", is_visible: true, name: { default: "Product" }, url: { default: "https://example.com" } }
            ],
            meta: { current_page: 1, per_page: 50, total: 1 }
          }.to_json
        )

      response = client.get_products(page: 1, per_page: 50)

      expect(response.data.size).to eq(1)
      expect(response.data.first.id).to eq("PROD-001")
      expect(response.current_page).to eq(1)
      expect(response.total).to eq(1)
    end
  end

  describe "#import_blogs" do
    it "sends blogs to API" do
      stub_request(:post, "https://api.pobo.space/api/v2/rest/blogs")
        .with(headers: { "Authorization" => "Bearer test-token" })
        .to_return(
          status: 200,
          body: { success: true, imported: 1, updated: 0, skipped: 0, errors: [] }.to_json
        )

      blog = Pobo::DTO::Blog.new(
        id: "BLOG-001",
        is_visible: true,
        name: Pobo::DTO::LocalizedString.create("Blog"),
        url: Pobo::DTO::LocalizedString.create("https://example.com/blog"),
        category: "news"
      )

      result = client.import_blogs([blog])

      expect(result.success).to be true
      expect(result.imported).to eq(1)
    end
  end

  describe "error handling" do
    it "raises ApiError for unauthorized" do
      stub_request(:get, "https://api.pobo.space/api/v2/rest/products")
        .to_return(status: 401, body: { error: "Unauthorized" }.to_json)

      expect { client.get_products }.to raise_error(Pobo::ApiError, "Authorization token required")
    end

    it "raises ApiError for server errors" do
      stub_request(:get, "https://api.pobo.space/api/v2/rest/products")
        .to_return(status: 500, body: { error: "Server error" }.to_json)

      expect { client.get_products }.to raise_error(Pobo::ApiError, "Server error")
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pobo::DTO::Blog do
  describe ".from_hash" do
    it "creates blog from hash" do
      hash = {
        "id" => "BLOG-001",
        "is_visible" => true,
        "category" => "news",
        "name" => { "default" => "Blog Title", "cs" => "Název blogu" },
        "url" => { "default" => "https://example.com/blog" },
        "description" => { "default" => "<p>Content</p>" },
        "is_loaded" => false,
        "created_at" => "2024-01-15T10:30:00.000000Z",
        "updated_at" => "2024-01-16T14:20:00.000000Z"
      }

      blog = described_class.from_hash(hash)

      expect(blog.id).to eq("BLOG-001")
      expect(blog.is_visible).to be true
      expect(blog.category).to eq("news")
      expect(blog.name.default).to eq("Blog Title")
      expect(blog.name.get(Pobo::Language::CS)).to eq("Název blogu")
      expect(blog.is_loaded).to be false
    end
  end

  describe "#to_hash" do
    it "converts blog to hash" do
      blog = described_class.new(
        id: "BLOG-001",
        is_visible: true,
        name: Pobo::DTO::LocalizedString.create("Blog Title"),
        url: Pobo::DTO::LocalizedString.create("https://example.com/blog"),
        category: "news"
      )

      hash = blog.to_hash

      expect(hash["id"]).to eq("BLOG-001")
      expect(hash["is_visible"]).to be true
      expect(hash["category"]).to eq("news")
      expect(hash["name"]).to eq({ "default" => "Blog Title" })
    end

    it "excludes nil optional fields" do
      blog = described_class.new(
        id: "BLOG-001",
        is_visible: true,
        name: Pobo::DTO::LocalizedString.create("Blog"),
        url: Pobo::DTO::LocalizedString.create("https://example.com")
      )

      hash = blog.to_hash

      expect(hash).not_to have_key("category")
      expect(hash).not_to have_key("description")
      expect(hash).not_to have_key("images")
    end
  end
end

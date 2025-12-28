# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pobo::DTO::LocalizedString do
  describe ".create" do
    it "creates instance with default value" do
      string = described_class.create("Default")
      expect(string.default).to eq("Default")
    end
  end

  describe "#with_translation" do
    it "adds translation immutably" do
      string = described_class.create("Default")
      string_with_cs = string.with_translation(Pobo::Language::CS, "Czech")

      expect(string.get(Pobo::Language::CS)).to be_nil
      expect(string_with_cs.get(Pobo::Language::CS)).to eq("Czech")
      expect(string_with_cs.default).to eq("Default")
    end
  end

  describe ".from_hash" do
    it "creates instance from hash" do
      hash = { "default" => "Default", "cs" => "Czech", "sk" => "Slovak" }
      string = described_class.from_hash(hash)

      expect(string.default).to eq("Default")
      expect(string.get(Pobo::Language::CS)).to eq("Czech")
      expect(string.get(Pobo::Language::SK)).to eq("Slovak")
    end

    it "returns nil for nil input" do
      expect(described_class.from_hash(nil)).to be_nil
    end
  end

  describe "#to_hash" do
    it "returns hash representation" do
      string = described_class.create("Default")
        .with_translation(Pobo::Language::CS, "Czech")

      expect(string.to_hash).to eq({
        "default" => "Default",
        "cs" => "Czech"
      })
    end
  end
end

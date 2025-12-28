# frozen_string_literal: true

module Pobo
  module Language
    DEFAULT = "default"
    CS = "cs"
    SK = "sk"
    EN = "en"
    DE = "de"
    PL = "pl"
    HU = "hu"

    ALL = [DEFAULT, CS, SK, EN, DE, PL, HU].freeze

    def self.valid?(code)
      ALL.include?(code)
    end
  end
end

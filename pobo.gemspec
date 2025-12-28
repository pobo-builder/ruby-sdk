# frozen_string_literal: true

require_relative "lib/pobo/version"

Gem::Specification.new do |spec|
  spec.name = "pobo-sdk"
  spec.version = Pobo::VERSION
  spec.authors = ["Pobo"]
  spec.email = ["tomas@pobo.cz"]

  spec.summary = "Official Ruby SDK for Pobo API V2"
  spec.description = "Ruby SDK for Pobo API V2 - product content management and webhooks"
  spec.homepage = "https://github.com/pobo-builder/ruby-sdk"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-net_http", "~> 3.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
end

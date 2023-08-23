# frozen_string_literal: true

require_relative "lib/kickplan/version"

Gem::Specification.new do |spec|
  spec.name          = "kickplan-sdk"
  spec.version       = Kickplan::VERSION
  spec.authors       = ["Will Clark"]
  spec.email         = ["will@kickplan.com"]

  spec.summary       = "SDK for Kickplan, a SaaS monetization infrastructure provider."
  spec.description   = "Kickplan lets you monetize your SaaS app by providing billing, feature access and authorization infrastructure."
  spec.homepage      = "https://github.com/kickplan/sdk-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files         = Dir["{lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end

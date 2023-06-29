# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "kickplan-sdk"
  spec.version       = "0.1.0"
  spec.authors       = ["Will Clark"]
  spec.email         = ["will@kickplan.com"]
  spec.summary       = "SDK for Kickplan, a SaaS monetization infrastructure provider."
  spec.description   = "Kickplan lets you monetize your SaaS app by providing billing, feature access and authorization infrastructure."
  spec.homepage      = "https://github.com/kickplan/sdk-ruby"
  spec.license       = "MIT"

  spec.files         = Dir["{lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
end

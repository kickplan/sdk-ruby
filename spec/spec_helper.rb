# frozen_string_literal: true

require "dotenv"
require "vcr"

Dotenv.load

require "kickplan"

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end
  config.order = :random
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :faraday, :webmock
  c.configure_rspec_metadata!

  c.filter_sensitive_data("<KICKPLAN_ENDPOINT>") {
    ENV.fetch("KICKPLAN_ENDPOINT", "kickplan-endpoint")
  }
end

Kickplan.configure do |config|
  config.endpoint = ENV["KICKPLAN_ENDPOINT"]
end

# frozen_string_literal: true

require "pact/consumer/rspec"
require "kickplan"

Pact.service_consumer "KickplanSDK" do
  has_pact_with "KickplanAPI" do
    mock_service :kickplan_api do
      port 1234
    end
  end
end

Kickplan[:pact].configure do |config|
  config.adapter = :http
  config.endpoint = "http://localhost:1234/api"
  config.access_token = "pact-test-token"
end

Pact.configure do |config|
  config.pact_dir = File.expand_path("pacts", __dir__)
  config.log_dir = File.expand_path("../spec/pact_logs", __dir__)
end

module PactHelpers
  def pact_client
    Kickplan.client(:pact)
  end
end

RSpec.configure do |config|
  config.include PactHelpers
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe Kickplan::Adapters::HTTP do
  Kickplan[:http].configure do |config|
    config.adapter = :http
    config.endpoint = ENV.fetch("KICKPLAN_ENDPOINT", "https://example.com/")
  end

  let(:client) { Kickplan.client(:http) }

  # Test the adapter through the resource interface
  let(:accounts) { client::Accounts }
  let(:features) { client::Features }

  subject(:adapter) { client.adapter }

  describe "#resolve_feature", vcr: { cassette_name: "resolve/feature" } do
    let(:key) { "digital-merch-products" }
    let(:params) {{
      context: {
        account_key: "a6a9cd9a-77af-4c1a-bc8d-4339eb00a081"
      }
    }}

    it "creates a POST request for 'features/:key'" do
      expect(adapter.connection).to receive(:post).
        with("features/#{key}", hash_including(params)).
        and_call_original

      features.resolve(key, params)
    end

    it "returns Kickplan::Responses::Resolution", :aggregate_failures do
      response = features.resolve(key, params)

      expect(response).to be_a Kickplan::Responses::Resolution
      expect(response.key).to eq key
      expect(response.value).to_not be_nil
    end
  end

  describe "#resolve_features", vcr: { cassette_name: "resolve/features" } do
    let(:params) {{
      context: {
        account_key: "a6a9cd9a-77af-4c1a-bc8d-4339eb00a081"
      }
    }}

    it "creates a POST request for 'features'" do
      expect(adapter.connection).to receive(:post).
        with("features", hash_including(params)).
        and_call_original

      features.resolve(params)
    end

    it "returns an array of Kickplan::Responses::Resolution", :aggregate_failures do
      response = features.resolve(params)

      expect(response).to be_a Array
      expect(response).to all be_a Kickplan::Responses::Resolution
    end
  end
end

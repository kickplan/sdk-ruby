# frozen_string_literal: true

require "spec_helper"

RSpec.describe Kickplan::Adapters::HTTP do
  Kickplan[:http].configure do |config|
    config.adapter = :http
    config.endpoint = ENV.fetch("KICKPLAN_ENDPOINT", "https://example.com/api")
  end

  let(:client) { Kickplan.client(:http) }

  # Test the adapter through the resource interface
  let(:accounts) { client::Accounts }
  let(:metrics) { client::Metrics }
  let(:features) { client::Features }

  subject(:adapter) { client.adapter }

  describe "#create_account", vcr: { cassette_name: "accounts/create" } do
    let(:params) {{
      key: "acme",
      name: "Acme Inc.",
      account_plans: [{ plan_key: "small" }],
      custom_fields: { "salesforce-id" => "1234" },
      feature_overrides: [{
        override: "variant_key",
        feature_key: "metrics",
        variant_key: "true"
      }]
    }}

    it "creates a POST request for 'accounts'" do
      expect(adapter.connection).to receive(:post).
        with("accounts", hash_including(params)).
        and_call_original

      accounts.create(params)
    end

    it "returns Kickplan::Schemas::Account", :aggregate_failures do
      response = accounts.create(params)

      expect(response).to be_a Kickplan::Schemas::Account
      expect(response.key).to eq "acme"
      expect(response.name).to eq "Acme Inc."
    end
  end

  describe "#resolve_feature", vcr: { cassette_name: "features/resolve" } do
    let(:key) { "seats" }
    let(:params) {{
      context: {
        account_key: "9a592f57-6da0-408e-99e7-8918b48a7dbe"
      }
    }}

    it "creates a POST request for 'features/:key'" do
      expect(adapter.connection).to receive(:post).
        with("features/#{key}/resolve", hash_including(params)).
        and_call_original

      features.resolve(key, params)
    end

    it "returns Kickplan::Schemas::Resolution", :aggregate_failures do
      response = features.resolve(key, params)

      expect(response).to be_a Kickplan::Schemas::Resolution
      expect(response.key).to eq key
      expect(response.value).to_not be_nil
    end
  end

  describe "#resolve_features", vcr: { cassette_name: "features/resolve-all" } do
    let(:params) {{
      context: {
        account_key: "9a592f57-6da0-408e-99e7-8918b48a7dbe"
      }
    }}

    it "creates a POST request for 'features'" do
      expect(adapter.connection).to receive(:post).
        with("features/resolve", hash_including(params)).
        and_call_original

      features.resolve(params)
    end

    it "returns an array of Kickplan::Schemas::Resolution", :aggregate_failures do
      response = features.resolve(params)

      expect(response).to be_a Array
      expect(response).to all be_a Kickplan::Schemas::Resolution
    end
  end

  describe "#set_metric", vcr: { cassette_name: "metrics/set" } do
    let(:params) {{
      key: "seats_used",
      value: 3,
      account_key: "9a592f57-6da0-408e-99e7-8918b48a7dbe",
      time: DateTime.now()
    }}

    it "creates a POST request for 'metrics/set'" do
      expect(adapter.connection).to receive(:post).
        with("metrics/set", params).
        and_call_original

      expect(metrics.set(params)).to be true
    end
  end

  describe "#update_account", vcr: { cassette_name: "accounts/update" } do
    let(:key) { "acme" }
    let(:params) {{
      name: "Acme Inc.",
      account_plans: [{ plan_key: "large" }],
      custom_fields: { "salesforce-id" => "4321" },
      feature_overrides: [{
        override: "variant_key",
        feature_key: "metrics",
        variant_key: "false"
      }]
    }}

    it "creates a POST request for 'accounts/:key'" do
      expect(adapter.connection).to receive(:put).
        with("accounts/#{key}", hash_including(params)).
        and_call_original

      accounts.update(key, params)
    end

    it "returns Kickplan::Schemas::Account", :aggregate_failures do
      response = accounts.update(key, params)

      expect(response).to be_a Kickplan::Schemas::Account
      expect(response.key).to eq "acme"
      expect(response.name).to eq "Acme Inc."
    end
  end
end

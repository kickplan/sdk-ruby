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

    it "returns Kickplan::Responses::Resolution", :aggregate_failures do
      response = features.resolve(key, params)

      expect(response).to be_a Kickplan::Responses::Resolution
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

    it "returns an array of Kickplan::Responses::Resolution", :aggregate_failures do
      response = features.resolve(params)

      expect(response).to be_a Array
      expect(response).to all be_a Kickplan::Responses::Resolution
    end
  end

  describe "#update_metric" do
    let(:key) { "seats_used" }
    let(:value) { 3 }
    let(:context) {{ account_key: "9a592f57-6da0-408e-99e7-8918b48a7dbe" }}
    let(:params) {{ value: value, context: context }}

    context "when performing a `decrement` on the metric",
      vcr: { cassette_name: "metrics/decrement" } do
      it "creates a POST request for 'metrics/:key/decrement'" do
        expect(adapter.connection).to receive(:post).
          with("metrics/#{key}/decrement", params).
          and_call_original

        metrics.decrement(key, value, context)
      end
    end

    context "when performing a `increment` on the metric",
      vcr: { cassette_name: "metrics/increment" } do
      it "creates a POST request for 'metrics/:key/increment'" do
        expect(adapter.connection).to receive(:post).
          with("metrics/#{key}/increment", params).
          and_call_original

        metrics.increment(key, value, context)
      end
    end

    context "when performing a `set` on the metric",
      vcr: { cassette_name: "metrics/set" } do
      it "creates a POST request for 'metrics/:key/set'" do
        expect(adapter.connection).to receive(:post).
          with("metrics/#{key}/set", params).
          and_call_original

        metrics.set(key, value, context)
      end
    end
  end
end

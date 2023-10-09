# frozen_string_literal: true

require "spec_helper"

RSpec.describe Kickplan::Adapters::HTTP do
  let(:client) { Kickplan.client(:example) }

  subject(:adapter) { described_class.new(client.config) }

  describe "#resolve", vcr: { cassette_name: "resolve/feature" } do
    let(:key) { "digital-merch-products" }
    let(:params) {{
      context: {
        account_id: "a6a9cd9a-77af-4c1a-bc8d-4339eb00a081"
      }
    }}

    it "creates a POST request for 'features/:key'" do
      expect(adapter.connection).to receive(:post).
        with("features/#{key}", hash_including(params)).
        and_call_original

      adapter.resolve(key, params)
    end

    it "returns the response body", :aggregate_failures do
      response = adapter.resolve(key, params)

      expect(response).to be_a Hash
      expect(response.keys).to include "key"
      expect(response.keys).to include "value"
    end

    context "when calling without a key",
      vcr: { cassette_name: "resolve/features" } do
      it "creates a POST request for 'features/'" do
        expect(adapter.connection).to receive(:post).
          with("features/", hash_including(params)).
          and_call_original

        adapter.resolve(params)
      end

      it "returns the response body", :aggregate_failures do
        response = adapter.resolve(params)

        expect(response).to be_a Array
        expect(response.first.keys).to include "key"
        expect(response.first.keys).to include "value"
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe Kickplan::Resources::Features do
  let(:client) { Kickplan.client(:example) }

  subject(:features) { described_class.new(client) }

  describe "#resolve", vcr: { cassette_name: "resolve/feature" } do
    let(:key) { "digital-merch-products" }
    let(:params) {{
      context: {
        account_id: "a6a9cd9a-77af-4c1a-bc8d-4339eb00a081"
      }
    }}

    it "returns a Responses::Resolution", :aggregate_failures do
      resolution = features.resolve(key, params)

      expect(resolution).to be_a Kickplan::Responses::Resolution
      expect(resolution.key).to eq key
      expect(resolution.to_h).to_not include :metadata
    end

    context "when requesting detailed results",
      vcr: { cassette_name: "resolve/feature-detailed" } do
      before { params[:detailed] = true }

      it "returns a detailed Responses::Resolution", :aggregate_failures do
        resolution = features.resolve(key, params)

        expect(resolution).to be_a Kickplan::Responses::Resolution
        expect(resolution.key).to eq key
        expect(resolution.to_h).to include :metadata
      end
    end

    context "when calling without a key",
      vcr: { cassette_name: "resolve/features" } do
      it "returns an array of Responses::Resolution", :aggregate_failures do
        resolutions = features.resolve(params)

        expect(resolutions).to all be_a Kickplan::Responses::Resolution
        expect(resolutions.first.to_h).to_not include :metadata
      end
    end
  end
end

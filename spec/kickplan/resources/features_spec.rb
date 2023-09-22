# frozen_string_literal: true

require "spec_helper"

RSpec.describe Kickplan::Features do
  subject(:features) { described_class }

  describe ".variant", vcr: { cassette_name: "feature" } do
    let(:key) { "digital-merch-products" }
    let(:params) {{
      context: {
        account_id: "a6a9cd9a-77af-4c1a-bc8d-4339eb00a081"
      }
    }}

    it "creates a POST request for 'features/:key'" do
      expect(Kickplan.client).to receive(:post).
        with("features/#{key}", hash_including(params)).and_call_original

      features.variant(key, params)
    end

    it "returns a Responses::Resolution", :aggregate_failures do
      resolution = features.variant(key, params)

      expect(resolution).to be_a Kickplan::Responses::Resolution
      expect(resolution.key).to eq key
      expect(resolution.to_h).to_not include :metadata
    end

    context "when requesting detailed results",
      vcr: { cassette_name: "feature-detailed" } do
      before { params[:detailed] = true }

      it "returns a detailed Responses::Resolution", :aggregate_failures do
        resolution = features.variant(key, params)

        expect(resolution).to be_a Kickplan::Responses::Resolution
        expect(resolution.key).to eq key
        expect(resolution.to_h).to include :metadata
      end
    end
  end

  describe ".variants", vcr: { cassette_name: "features" } do
    let(:params) {{
      context: {
        account_id: "a6a9cd9a-77af-4c1a-bc8d-4339eb00a081"
      }
    }}

    it "creates a POST request for 'features'" do
      expect(Kickplan.client).to receive(:post).
        with("features", hash_including(params)).and_call_original

      features.variants(params)
    end

    it "returns an array of Responses::Resolution", :aggregate_failures do
      resolutions = features.variants(params)

      expect(resolutions).to all be_a Kickplan::Responses::Resolution
      expect(resolutions.first.to_h).to_not include :metadata
    end

    context "when requesting detailed results",
      vcr: { cassette_name: "features-detailed" } do
      before { params[:detailed] = true }

      it "returns an array of detailed Responses::Resolution", :aggregate_failures do
        resolutions = features.variants(params)

        expect(resolutions).to all be_a Kickplan::Responses::Resolution
        expect(resolutions.first.to_h).to include :metadata
      end
    end
  end
end

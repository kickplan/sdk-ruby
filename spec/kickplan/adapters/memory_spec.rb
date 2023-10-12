# frozen_string_literal: true

require "spec_helper"

RSpec.describe Kickplan::Adapters::Memory do
  Kickplan[:memory].configure do |config|
    config.adapter = :memory
  end

  let(:client) { Kickplan.client(:memory) }

  # Test the adapter through the resource interface
  let(:accounts) { client::Accounts }
  let(:features) { client::Features }

  subject(:adapter) { client.adapter }

  before { client.reset }

  describe "#configure_account", :aggregate_failures do
    let(:store) { adapter.accounts }

    it "sets the configuration in the account store" do
      expect(store).to be_empty

      accounts.configure("123", "chat", "false")
      expect(store).to_not be_empty
      expect(store["123"].overrides).to include("chat" => "false")
      expect(store["123"].overrides.size).to eq 1

      accounts.configure("123", "chat", "true")
      expect(store["123"].overrides).to include("chat" => "true")

      accounts.configure("123", "geoblocking", "true")
      expect(store["123"].overrides).to include("geoblocking" => "true")
      expect(store["123"].overrides.size).to eq 2
    end

    it "returns true" do
      expect(accounts.configure("123", "chat", "false")).to eq true
    end
  end

  describe "#configure_feature" do
    let(:store) { adapter.features }

    it "sets the configuration in the features store" do
      expect(store).to be_empty

      features.configure("chat")
      expect(store).to_not be_empty
      expect(store["chat"].default).to eq "false"

      features.configure("chat", default: "true")
      expect(store).to_not be_empty
      expect(store["chat"].default).to eq "true"
    end

    it "returns true" do
      expect(features.configure("chat")).to eq true
    end
  end

  describe "#resolve_feature", skip: true
  describe "#resolve_features", skip: true
end

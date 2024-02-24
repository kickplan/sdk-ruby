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
  let(:metrics)  { client::Metrics }

  subject(:adapter) { client.adapter }

  before { client.reset }

  describe "#create_account" do
    let(:store) { adapter.accounts }

    it "stores the account in the account store", :aggregate_failures do
      expect(store).to be_empty

      accounts.create(key: "acme", name: "Acme Inc")
      expect(store).to_not be_empty
      expect(store["acme"]).to be_a Kickplan::Schemas::Account
      expect(store["acme"].name).to eq "Acme Inc"
    end

    context "when the account already exists" do
      it "raises a BadRequest error" do
        accounts.create(key: "acme")

        expect { accounts.create(key: "acme") }.
          to raise_error(Kickplan::Errors::BadRequest)
      end
    end
  end

  describe "#configure_account" do
    let(:store) { adapter.overrides }

    it "sets the configuration in the account store", :aggregate_failures do
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
  end

  describe "#configure_feature" do
    let(:store) { adapter.features }

    it "sets the configuration in the features store", :aggregate_failures do
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

  describe "#create_account" do
    let(:store) { adapter.accounts }
    let(:params) {{ key: "acme", name: "Acme Inc." }}

    it "stores a new account", :aggregate_failures do
      expect(store).to be_empty

      response = accounts.create(params)

      expect(response).to be_a Kickplan::Schemas::Account
      expect(response.key).to eq "acme"
      expect(response.name).to eq "Acme Inc."
      expect(store["acme"]).to be response
    end

    context "when an account already exists" do
      it "raises a BadRequest error" do
        accounts.create(params)

        expect { accounts.create(params) }.
          to raise_error(Kickplan::Errors::BadRequest)
      end
    end
  end

  describe "#resolve_feature" do
    before "configure feature" do
      features.configure("seats", {
        name: "Seats",
        default: "small",
        variants: { "small" => 10, "large" => 50 }
      })
    end

    it "returns the default value", :aggregate_failures do
      resolution = features.resolve("seats")

      expect(resolution).to be_a Kickplan::Schemas::Resolution
      expect(resolution.key).to eq "seats"
      expect(resolution.value).to eq 10
    end

    context "when given an account context", :aggregate_failures do
      it "resolves using the accounts configured overrides" do
        resolution = features.resolve("seats", context: { account_key: "123" })
        expect(resolution.value).to eq 10

        accounts.configure("123", "seats", "large")

        resolution = features.resolve("seats", context: { account_key: "123" })
        expect(resolution.value).to eq 50
      end
    end

    context "when detailed response is requested" do
      it "returns a detailed response" do
        resolution = features.resolve("seats", detailed: true)
        expect(resolution.metadata).to include "name" => "Seats"
      end
    end

    context "when the feature doesn't exist" do
      it "raises a Kickplan::ClientError" do
        expect { features.resolve("unknown") }.
          to raise_error(Kickplan::ClientError)
      end
    end
  end

  describe "#resolve_features" do
    before "configure features" do
      features.configure("chat")
      features.configure("seats", {
        default: "small",
        variants: { "small" => 10, "large" => 50 }
      })
    end

    it "resolves all features", :aggregate_failures do
      resolution = features.resolve

      expect(resolution).to be_a Array
      expect(resolution).to all be_a Kickplan::Schemas::Resolution
      expect(resolution.size).to eq 2
      expect(resolution.map(&:key)).to match_array(["chat", "seats"])
    end
  end

  describe "#update_account" do
    let(:store) { adapter.accounts }
    let(:key) { "acme" }
    let(:params) {{ name: "Acme Inc." }}

    it "updates an account in the account store", :aggregate_failures do
      accounts.create(key: key, name: "Old Name")

      response = accounts.update(key, params)

      expect(response).to be_a Kickplan::Schemas::Account
      expect(response.key).to eq "acme"
      expect(response.name).to eq "Acme Inc."
      expect(store["acme"]).to be response
    end

    context "when the account doesn't exist" do
      it "raises a NotFound error" do
        expect { accounts.update(key, params) }.
          to raise_error(Kickplan::Errors::NotFound)
      end
    end
  end

  describe "#update_metric" do
    let(:store) { adapter.metrics }

    let(:key) { "seats_used" }
    let(:account_key) { "a6a9cd9a-77af-4c1a-bc8d-4339eb00a081" }
    let(:store_key) { [key, account_key].join(".") }

    context "when performing a `decrement` on the metric" do
      it "decrements the value in the metrics store", :aggregate_failures do
        expect(store).to be_empty

        metrics.decrement(key, account_key: account_key)
        expect(store).to_not be_empty
        expect(store[store_key]).to eq -1

        metrics.decrement(key, 3, account_key: account_key)
        expect(store[store_key]).to eq -4
      end
    end

    context "when performing a `increment` on the metric" do
      it "increments the value in the metrics store", :aggregate_failures do
        expect(store).to be_empty

        metrics.increment(key, account_key: account_key)
        expect(store).to_not be_empty
        expect(store[store_key]).to eq 1

        metrics.increment(key, 3, account_key: account_key)
        expect(store[store_key]).to eq 4
      end
    end

    context "when performing a `set` on the metric" do
      it "sets the value in the metrics store", :aggregate_failures do
        expect(store).to be_empty

        metrics.set(key, account_key: account_key)
        expect(store).to_not be_empty
        expect(store[store_key]).to eq 1

        metrics.set(key, 3, account_key: account_key)
        expect(store[store_key]).to eq 3
      end
    end
  end
end

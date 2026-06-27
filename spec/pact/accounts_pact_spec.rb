# frozen_string_literal: true

require "pact_helper"

RSpec.describe "Accounts Pact", pact: true do
  let(:accounts) { pact_client::Accounts }

  describe "create account" do
    before do
      kickplan_api
        .given("a valid environment")
        .upon_receiving("a request to create an account")
        .with(
          method: :post,
          path: "/api/accounts",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            key: "acme",
            name: "Acme Inc.",
            custom_fields: { "tier" => "gold" },
            account_plans: [{ plan_key: "small" }],
            feature_overrides: [
              { feature_key: "contact-limit", override: "variant_key", variant_key: "high" }
            ]
          }
        )
        .will_respond_with(
          status: 201,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) },
          body: {
            key: Pact.like("acme"),
            name: Pact.like("Acme Inc."),
            custom_fields: Pact.like({ "tier" => "gold" }),
            account_plans: Pact.each_like("small"),
            feature_overrides: Pact.each_like(
              feature_key: "contact-limit",
              variant_key: "high"
            )
          }
        )
    end

    it "returns an Account" do
      response = accounts.create(
        key: "acme",
        name: "Acme Inc.",
        custom_fields: { "tier" => "gold" },
        account_plans: [{ plan_key: "small" }],
        feature_overrides: [
          { feature_key: "contact-limit", override: "variant_key", variant_key: "high" }
        ]
      )

      expect(response).to be_a Kickplan::Schemas::Account
      expect(response.key).to eq "acme"
      expect(response.custom_fields).to eq("tier" => "gold")
      expect(response.account_plans).to eq(["small"])
    end
  end

  describe "create account (validation error)" do
    before do
      kickplan_api
        .given("a valid environment")
        .upon_receiving("a request to create an account with a missing key")
        .with(
          method: :post,
          path: "/api/accounts",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            name: "Acme Inc."
          }
        )
        .will_respond_with(
          status: 400,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) }
        )
    end

    it "raises a BadRequest error" do
      expect do
        pact_client.adapter.post("accounts", { name: "Acme Inc." })
      end.to raise_error(Kickplan::Errors::BadRequest)
    end
  end

  describe "update account (PUT)" do
    before do
      kickplan_api
        .given("an account with key 'acme' exists")
        .upon_receiving("a request to update an account via PUT")
        .with(
          method: :put,
          path: "/api/accounts/acme",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            name: "Acme Corp.",
            custom_fields: { "tier" => "platinum" },
            account_plans: [{ plan_key: "large" }],
            feature_overrides: [
              { feature_key: "contact-limit", override: "default_on" }
            ]
          }
        )
        .will_respond_with(
          status: 200,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) },
          body: {
            key: Pact.like("acme"),
            name: Pact.like("Acme Corp."),
            custom_fields: Pact.like({ "tier" => "platinum" }),
            account_plans: Pact.each_like("large"),
            feature_overrides: Pact.each_like(
              feature_key: "contact-limit",
              override: "default_on"
            )
          }
        )
    end

    it "returns an updated Account" do
      response = accounts.update("acme",
        name: "Acme Corp.",
        custom_fields: { "tier" => "platinum" },
        account_plans: [{ plan_key: "large" }],
        feature_overrides: [
          { feature_key: "contact-limit", override: "default_on" }
        ]
      )

      expect(response).to be_a Kickplan::Schemas::Account
      expect(response.key).to eq "acme"
    end
  end

  describe "update account (PATCH)" do
    before do
      kickplan_api
        .given("an account with key 'acme' exists")
        .upon_receiving("a request to update an account via PATCH")
        .with(
          method: :patch,
          path: "/api/accounts/acme",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            name: "Acme Corp.",
            custom_fields: { "tier" => "platinum" },
            account_plans: [{ plan_key: "large" }],
            feature_overrides: [
              { feature_key: "contact-limit", override: "default_off" }
            ]
          }
        )
        .will_respond_with(
          status: 200,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) },
          body: {
            key: Pact.like("acme"),
            name: Pact.like("Acme Corp."),
            custom_fields: Pact.like({ "tier" => "platinum" }),
            account_plans: Pact.each_like("large"),
            feature_overrides: Pact.each_like(
              feature_key: "contact-limit",
              override: "default_off"
            )
          }
        )
    end

    it "returns an updated Account" do
      params = Kickplan::Requests::Accounts::Update.new(
        name: "Acme Corp.",
        custom_fields: { "tier" => "platinum" },
        account_plans: [{ plan_key: "large" }],
        feature_overrides: [
          { feature_key: "contact-limit", override: "default_off" }
        ]
      )

      response = pact_client.adapter.patch("accounts/acme", params.to_h)

      expect(response.status).to eq 200
      expect(response.body["key"]).to eq "acme"
    end
  end

  describe "update account (not found)" do
    before do
      kickplan_api
        .given("no account with key 'ghost' exists")
        .upon_receiving("a request to update a missing account")
        .with(
          method: :put,
          path: "/api/accounts/ghost",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            name: "Ghost Corp."
          }
        )
        .will_respond_with(
          status: 400,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) }
        )
    end

    it "raises a BadRequest error" do
      expect do
        pact_client.adapter.put("accounts/ghost", { name: "Ghost Corp." })
      end.to raise_error(Kickplan::Errors::BadRequest)
    end
  end

  describe "update account (PATCH, not found)" do
    before do
      kickplan_api
        .given("no account with key 'ghost' exists")
        .upon_receiving("a PATCH request to update a missing account")
        .with(
          method: :patch,
          path: "/api/accounts/ghost",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            name: "Ghost Corp."
          }
        )
        .will_respond_with(
          status: 400,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) }
        )
    end

    it "raises a BadRequest error" do
      expect do
        pact_client.adapter.patch("accounts/ghost", { name: "Ghost Corp." })
      end.to raise_error(Kickplan::Errors::BadRequest)
    end
  end
end

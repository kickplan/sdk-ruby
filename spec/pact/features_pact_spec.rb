# frozen_string_literal: true

require "pact_helper"

RSpec.describe "Features Pact", pact: true do
  let(:features) { pact_client::Features }

  describe "resolve single feature" do
    before do
      kickplan_api
        .given("an account with key 'acme' exists")
        .upon_receiving("a request to resolve a single feature")
        .with(
          method: :post,
          path: "/api/features/contact-limit/resolve",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            detailed: false,
            context: { account_key: "acme" }
          }
        )
        .will_respond_with(
          status: 200,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) },
          body: {
            key: Pact.like("contact-limit"),
            value: Pact.like(10)
          }
        )
    end

    it "returns a Resolution" do
      response = features.resolve("contact-limit", context: { account_key: "acme" })

      expect(response).to be_a Kickplan::Schemas::Resolution
      expect(response.key).to eq "contact-limit"
      expect(response.value).not_to be_nil
    end
  end

  describe "resolve single feature (detailed)" do
    before do
      kickplan_api
        .given("an account with key 'acme' exists")
        .upon_receiving("a request to resolve a single feature in detail")
        .with(
          method: :post,
          path: "/api/features/contact-limit/resolve",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            detailed: true,
            context: { account_key: "acme" }
          }
        )
        .will_respond_with(
          status: 200,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) },
          body: {
            key: Pact.like("contact-limit"),
            value: Pact.like(10),
            variant: Pact.like("high"),
            reason: Pact.like("TARGETING_MATCH"),
            metadata: Pact.like({ "name" => "Contact Limit" }),
            error_code: Pact.like(nil),
            error_message: Pact.like(nil)
          }
        )
    end

    it "returns a detailed Resolution" do
      response = features.resolve("contact-limit", detailed: true, context: { account_key: "acme" })

      expect(response).to be_a Kickplan::Schemas::Resolution
      expect(response.variant).to eq "high"
      expect(response.metadata).to eq("name" => "Contact Limit")
    end
  end

  describe "resolve single feature (not found)" do
    before do
      kickplan_api
        .given("an account with key 'acme' exists")
        .upon_receiving("a request to resolve a missing feature")
        .with(
          method: :post,
          path: "/api/features/ghost-flag/resolve",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            detailed: false,
            context: { account_key: "acme" }
          }
        )
        .will_respond_with(
          status: 400,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) }
        )
    end

    it "raises a BadRequest error" do
      params = Kickplan::Requests::Features::Resolve.new(context: { account_key: "acme" })
      expect do
        pact_client.adapter.post("features/ghost-flag/resolve", params.to_h)
      end.to raise_error(Kickplan::Errors::BadRequest)
    end
  end

  describe "resolve all features" do
    before do
      kickplan_api
        .given("an account with key 'acme' exists")
        .upon_receiving("a request to resolve all features")
        .with(
          method: :post,
          path: "/api/features/resolve",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            detailed: false,
            context: { account_key: "acme" }
          }
        )
        .will_respond_with(
          status: 200,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) },
          body: Pact.each_like(
            key: "contact-limit",
            value: 10
          )
        )
    end

    it "returns an array of Resolutions" do
      response = features.resolve(context: { account_key: "acme" })

      expect(response).to be_a Array
      expect(response).to all be_a Kickplan::Schemas::Resolution
    end
  end

  describe "resolve all features (no context, error)" do
    before do
      kickplan_api
        .given("a valid environment")
        .upon_receiving("a request to resolve all features without a context")
        .with(
          method: :post,
          path: "/api/features/resolve",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            detailed: false
          }
        )
        .will_respond_with(
          status: 400,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) }
        )
    end

    it "raises a BadRequest error" do
      expect do
        pact_client.adapter.post("features/resolve", { detailed: false })
      end.to raise_error(Kickplan::Errors::BadRequest)
    end
  end

  # POST /api/features is an alternate "resolve all" route (FeatureController#resolve).
  describe "resolve all features (POST /api/features)" do
    before do
      kickplan_api
        .given("an account with key 'acme' exists")
        .upon_receiving("a request to resolve all features via POST /api/features")
        .with(
          method: :post,
          path: "/api/features",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            detailed: true,
            context: { account_key: "acme" }
          }
        )
        .will_respond_with(
          status: 200,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) },
          body: Pact.each_like(
            key: "contact-limit",
            value: 10,
            variant: "high",
            reason: "TARGETING_MATCH",
            metadata: { "name" => "Contact Limit" },
            error_code: nil,
            error_message: nil
          )
        )
    end

    it "returns resolutions" do
      params = Kickplan::Requests::Features::Resolve.new(detailed: true, context: { account_key: "acme" })
      response = pact_client.adapter.post("features", params.to_h)

      expect(response.status).to eq 200
      expect(response.body.first["key"]).to eq "contact-limit"
    end
  end

  describe "resolve all features (POST /api/features, error)" do
    before do
      kickplan_api
        .given("a valid environment")
        .upon_receiving("a request to POST /api/features without a context")
        .with(
          method: :post,
          path: "/api/features",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            detailed: false
          }
        )
        .will_respond_with(
          status: 400,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) }
        )
    end

    it "raises a BadRequest error" do
      expect do
        pact_client.adapter.post("features", { detailed: false })
      end.to raise_error(Kickplan::Errors::BadRequest)
    end
  end

  # POST /api/features/:key is an alternate "resolve single" route (FeatureController#resolve).
  describe "resolve single feature (POST /api/features/:key)" do
    before do
      kickplan_api
        .given("an account with key 'acme' exists")
        .upon_receiving("a request to resolve a single feature via POST /api/features/:key")
        .with(
          method: :post,
          path: "/api/features/contact-limit",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            detailed: true,
            context: { account_key: "acme" }
          }
        )
        .will_respond_with(
          status: 200,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) },
          body: {
            key: Pact.like("contact-limit"),
            value: Pact.like(10),
            variant: Pact.like("high"),
            reason: Pact.like("TARGETING_MATCH"),
            metadata: Pact.like({ "name" => "Contact Limit" }),
            error_code: Pact.like(nil),
            error_message: Pact.like(nil)
          }
        )
    end

    it "returns a Resolution" do
      params = Kickplan::Requests::Features::Resolve.new(detailed: true, context: { account_key: "acme" })
      response = pact_client.adapter.post("features/contact-limit", params.to_h)

      expect(response.status).to eq 200
      expect(response.body["key"]).to eq "contact-limit"
    end
  end

  describe "resolve single feature (POST /api/features/:key, not found)" do
    before do
      kickplan_api
        .given("an account with key 'acme' exists")
        .upon_receiving("a request to POST /api/features/:key for a missing feature")
        .with(
          method: :post,
          path: "/api/features/ghost-flag",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            detailed: false,
            context: { account_key: "acme" }
          }
        )
        .will_respond_with(
          status: 400,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) }
        )
    end

    it "raises a BadRequest error" do
      params = Kickplan::Requests::Features::Resolve.new(context: { account_key: "acme" })
      expect do
        pact_client.adapter.post("features/ghost-flag", params.to_h)
      end.to raise_error(Kickplan::Errors::BadRequest)
    end
  end
end

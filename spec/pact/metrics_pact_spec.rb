# frozen_string_literal: true

require "pact_helper"
require "date"

RSpec.describe "Metrics Pact", pact: true do
  let(:metrics) { pact_client::Metrics }

  describe "set metric" do
    let(:time) { DateTime.parse("2026-06-14T12:00:00+00:00") }

    before do
      kickplan_api
        .given("an account with key 'acme' exists")
        .upon_receiving("a request to set a metric")
        .with(
          method: :post,
          path: "/api/metrics/set",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            key: "seats_used",
            value: 3,
            account_key: "acme",
            idempotency_key: "idem-2026-06-14",
            time: "2026-06-14T12:00:00+00:00"
          }
        )
        .will_respond_with(status: 202)
    end

    it "returns true" do
      result = metrics.set(
        key: "seats_used",
        value: 3,
        account_key: "acme",
        idempotency_key: "idem-2026-06-14",
        time: time
      )

      expect(result).to be true
    end
  end

  describe "set metric (validation error)" do
    before do
      kickplan_api
        .given("an account with key 'acme' exists")
        .upon_receiving("a request to set a metric with a missing value")
        .with(
          method: :post,
          path: "/api/metrics/set",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            key: "seats_used",
            account_key: "acme"
          }
        )
        .will_respond_with(
          status: 400,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) }
        )
    end

    it "raises a BadRequest error" do
      expect do
        pact_client.adapter.post("metrics/set", { key: "seats_used", account_key: "acme" })
      end.to raise_error(Kickplan::Errors::BadRequest)
    end
  end

  describe "flush metrics" do
    before do
      kickplan_api
        .given("a valid environment")
        .upon_receiving("a request to flush metrics")
        .with(
          method: :post,
          path: "/api/metrics/flush",
          headers: {
            "Authorization" => "Bearer pact-test-token"
          }
        )
        .will_respond_with(status: 202)
    end

    it "returns true" do
      result = metrics.flush

      expect(result).to be true
    end
  end

  describe "flush metrics (unauthorized)" do
    before do
      kickplan_api
        .given("a valid environment")
        .upon_receiving("an unauthorized request to flush metrics")
        .with(
          method: :post,
          path: "/api/metrics/flush",
          headers: {
            "Authorization" => "Bearer wrong-token"
          }
        )
        .will_respond_with(status: 401)
    end

    it "raises a ServiceError" do
      expect do
        pact_client.adapter.connection.post("metrics/flush") do |req|
          req.headers["Authorization"] = "Bearer wrong-token"
        end
      end.to raise_error(Kickplan::ServiceError)
    end
  end
end

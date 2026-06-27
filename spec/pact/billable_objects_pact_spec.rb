# frozen_string_literal: true

require "pact_helper"

RSpec.describe "BillableObjects Pact", pact: true do
  let(:billable_objects) { pact_client::BillableObjects }

  describe "upsert billable object" do
    before do
      kickplan_api
        .given("an account with key 'acme' exists")
        .upon_receiving("a request to upsert a billable object")
        .with(
          method: :post,
          path: "/api/billable_objects",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            external_id: "1234",
            external_type: "license",
            account_key: "acme",
            properties: { active: true }
          }
        )
        .will_respond_with(
          status: 201,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) },
          body: {
            external_id: Pact.like("1234"),
            external_type: Pact.like("license"),
            account_key: Pact.like("acme"),
            properties: Pact.like({ "active" => true })
          }
        )
    end

    it "returns a BillableObject" do
      response = billable_objects.upsert(
        external_id: "1234",
        external_type: "license",
        account_key: "acme",
        properties: { active: true }
      )

      expect(response).to be_a Kickplan::Schemas::BillableObject
      expect(response.external_id).to eq "1234"
    end
  end

  describe "upsert billable object (validation error)" do
    before do
      kickplan_api
        .given("a valid environment")
        .upon_receiving("a request to upsert a billable object with a missing account_key")
        .with(
          method: :post,
          path: "/api/billable_objects",
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer pact-test-token"
          },
          body: {
            external_id: "1234",
            external_type: "license"
          }
        )
        .will_respond_with(
          status: 400,
          headers: { "Content-Type" => Pact.term("application/json", /application\/json/) }
        )
    end

    it "raises a BadRequest error" do
      expect do
        pact_client.adapter.post("billable_objects", { external_id: "1234", external_type: "license" })
      end.to raise_error(Kickplan::Errors::BadRequest)
    end
  end
end

# frozen_string_literal: true

module Kickplan
  module Resources
    class BillableObjects < Resource
      def upsert(options = {})
        params = Requests::BillableObjects::Upsert.new(options)
        response = adapter.upsert_billable_object(params)

        Schemas::BillableObject.wrap(response)
      end
    end
  end
end

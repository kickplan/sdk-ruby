# frozen_string_literal: true

module Kickplan
  module Schemas
    class BillableObject < Schema
      attribute :external_id, Types::String
      attribute :external_type, Types::String
      attribute :account_key, Types::String
      attribute :properties, Types::Hash
    end
  end
end

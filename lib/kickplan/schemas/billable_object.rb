# frozen_string_literal: true

module Kickplan
  module Schemas
    class BillableObject < Schema
      attribute :object_id, Types::String
      attribute :object_type, Types::String
      attribute :account_key, Types::String
      attribute :properties, Types::Hash
    end
  end
end

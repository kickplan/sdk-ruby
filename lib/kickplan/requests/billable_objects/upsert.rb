# frozen_string_literal: true

module Kickplan
  module Requests
    module BillableObjects
      class Upsert < Request
        attribute :external_id, Types::String
        attribute :external_type, Types::String
        attribute :account_key, Types::String
        attribute? :properties, Types::Hash
      end
    end
  end
end

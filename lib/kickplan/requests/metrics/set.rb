# frozen_string_literal: true

module Kickplan
  module Requests
    module Metrics
      class Set < Request
        attribute :key, Types::String
        attribute :value, Types::Any
        attribute :account_key, Types::String
        attribute? :idempotency_key, Types::String
        attribute? :time, Types::DateTime
      end
    end
  end
end

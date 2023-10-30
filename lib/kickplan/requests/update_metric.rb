# frozen_string_literal: true

module Kickplan
  module Requests
    class UpdateMetric < Request
      attribute :action, Types::String.enum("decrement", "increment", "set")
      attribute :key, Types::String
      attribute :value, Types::Any

      attribute :context do
        attribute :account_key, Types::String
      end
    end
  end
end

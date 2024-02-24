# frozen_string_literal: true

module Kickplan
  module Requests
    module Metrics
      class Update < Request
        attribute :action, Types::String.enum("decrement", "increment", "set")
        attribute :key, Types::String
        attribute :value, Types::Any

        attribute :context do
          attribute :account_key, Types::String
        end
      end
    end
  end
end

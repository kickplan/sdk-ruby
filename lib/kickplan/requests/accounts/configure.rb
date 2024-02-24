# frozen_string_literal: true

module Kickplan
  module Requests
    module Accounts
      class Configure < Request
        attribute :key, Types::String
        attribute :overrides, Types::Hash

        def merge(other)
          new(
            key: key,
            overrides: overrides.merge(other.overrides)
          )
        end
      end
    end
  end
end

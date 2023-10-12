# frozen_string_literal: true

module Kickplan
  module Requests
    class ResolveFeature < Request
      attribute? :detailed, Types::Bool.default(false)
      attribute? :context do
        attribute? :account_key, Types::String.optional
      end
    end
  end
end

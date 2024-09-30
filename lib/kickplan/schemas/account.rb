# frozen_string_literal: true

module Kickplan
  module Schemas
    class Account < Schema
      attribute :key, Types::String
      attribute? :name, Types::String

      # @todo Update rpc response format
      attribute? :custom_fields, Types::Hash
      attribute? :account_plans, Types::Array.of(Types::String)
      attribute? :feature_overrides, Types::Array
    end
  end
end

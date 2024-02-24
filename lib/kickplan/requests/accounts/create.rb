# frozen_string_literal: true

module Kickplan
  module Requests
    module Accounts
      class Create < Request
        attribute :key, Types::String
        attribute? :name, Types::String.optional
        attribute? :custom_fields, Types::Hash

        attribute? :account_plans, Types::Array do
          attribute :plan_key, Types::String
        end

        attribute? :feature_overrides, Types::Array do
          attribute? :override, Types::String.default("variant_key").
            enum("default_on", "default_off", "variant_key")

          attribute? :expires_at, Types::DateTime
          attribute :feature_key, Types::String
          attribute? :variant_key, Types::String
        end
      end
    end
  end
end

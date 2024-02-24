# frozen_string_literal: true

module Kickplan
  module Resources
    class Accounts < Resource
      # @deprecated
      def configure(key, feature_key, feature_variant)
        params = Requests::Accounts::Configure.new(
          key: key,
          overrides: { feature_key => feature_variant }
        )

        adapter.configure_account(params)
      end

      def create(options = {})
        params = Requests::Accounts::Create.new(options)
        response = adapter.create_account(params)

        Schemas::Account.wrap(response)
      end

      def update(key, options = {})
        params = Requests::Accounts::Update.new(options)
        response = adapter.update_account(key, params)

        Schemas::Account.wrap(response)
      end
    end
  end
end

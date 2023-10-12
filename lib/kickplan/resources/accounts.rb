# frozen_string_literal: true

module Kickplan
  module Resources
    class Accounts < Resource
      def configure(key, feature_key, feature_variant)
        params = Requests::ConfigureAccount.new(
          key: key,
          overrides: { feature_key => feature_variant }
        )

        adapter.configure_account(params)
      end
    end
  end
end

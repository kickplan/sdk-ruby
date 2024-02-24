# frozen_string_literal: true

module Kickplan
  module Adapters
    class HTTP < Adapter
      extend Forwardable

      delegate %i(get post put delete) => :connection

      # @deprecated
      def configure_account(params)
        raise NotImplementedError,
          "#add_account_override is not defined for #{self.class}"
      end

      def create_account(params)
        post("accounts", params.to_h).body
      end

      # @todo Implement adapter interface method.
      def configure_feature(params)
        raise NotImplementedError,
          "#configure_feature is not defined for #{self.class}"
      end

      def resolve_feature(key, params)
        post("features/#{key}/resolve", params.to_h).body
      end

      def resolve_features(params)
        post("features/resolve", params.to_h).body
      end

      def update_account(key, params)
        put("accounts/#{key}", params.to_h).body
      end

      def update_metric(params)
        path = ["metrics", params.key, params.action].join("/")

        post(path, params.to_h.slice(:value, :context)).body
      end

      # @api private
      def connection
        memoize do
          Faraday::Connection.new(
            url: config.endpoint,
            proxy: config.proxy,
            builder: config.middleware,
            headers: {
              user_agent: config.user_agent
            }
          )
        end
      end
    end
  end

  Adapters.register(:http, Adapters::HTTP)
end

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

      def flush_metrics
        post("metrics/flush").success?
      end

      def resolve_feature(key, params)
        post("features/#{key}/resolve", params.to_h).body
      end

      def resolve_features(params)
        post("features/resolve", params.to_h).body
      end

      def set_metric(params)
        post("metrics/set", params.to_h).success?
      end

      def update_account(key, params)
        put("accounts/#{key}", params.to_h).body
      end

      # @api private
      def connection
        memoize do
          Faraday::Connection.new(
            url: config.endpoint,
            proxy: config.proxy,
            builder: config.middleware,
            headers: {
              authorization: "Bearer #{config.access_token}",
              user_agent: config.user_agent
            }
          )
        end
      end
    end
  end

  Adapters.register(:http, Adapters::HTTP)
end

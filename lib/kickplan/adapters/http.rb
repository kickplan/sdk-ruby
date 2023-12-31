# frozen_string_literal: true

module Kickplan
  module Adapters
    class HTTP < Adapter
      extend Forwardable

      delegate %i(get post put delete) => :connection

      # @todo Implement adapter interface method.
      def configure_account(params)
        false
      end

      # @todo Implement adapter interface method.
      def configure_feature(params)
        false
      end

      def resolve_feature(key, params)
        post("features/#{key}/resolve", params.to_h).body
      end

      def resolve_features(params)
        post("features/resolve", params.to_h).body
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

# frozen_string_literal: true

module Kickplan
  module Adapters
    class HTTP < Adapter
      extend Forwardable

      delegate %i(get post put delete) => :connection

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

      def resolve(key = nil, params = {})
        if key.nil? || key.is_a?(Hash)
          key, params = nil, key
        end

        post("features/#{key}", params).body
      end
    end
  end

  Adapters.register(:http, Adapters::HTTP)
end

# frozen_string_literal: true

require "faraday"

# Explicit requires for Faraday < 2.0
require "faraday/request/json"
require "faraday/response/json"

module Kickplan
  require_relative "middleware/raise_error"
  require_relative "version"

  module Default
    ADAPTER = :memory

    ENDPOINT = "https://service.kickplan.io/api"

    MIDDLEWARE = Faraday::RackBuilder.new do |builder|
      builder.use Faraday::Request::Json
      builder.use Faraday::Response::Json
      builder.use Middleware::RaiseError
      builder.adapter Faraday.default_adapter
    end

    USER_AGENT = "Kickplan SDK v#{VERSION}"

    class << self
      def access_token
        ENV.fetch("KICKPLAN_ACCESS_TOKEN", nil)
      end

      def adapter
        ENV.fetch("KICKPLAN_ADAPTER", ADAPTER)
      end

      def endpoint
        ENV.fetch("KICKPLAN_ENDPOINT", ENDPOINT)
      end

      def middleware
        MIDDLEWARE
      end

      def proxy
        ENV.fetch("KICKPLAN_PROXY", nil)
      end

      def user_agent
        ENV.fetch("KICKPLAN_USER_AGENT", USER_AGENT)
      end
    end
  end
end

# frozen_string_literal: true

require "faraday"

module Kickplan
  module Middleware
    # In Faraday 2.x, Faraday::Response::Middleware was removed
    Base = defined?(Faraday::Response::Middleware) ? Faraday::Response::Middleware : Faraday::Middleware
  end
end

# frozen_string_literal: true

require "dry/configurable"

module Kickplan
  require_relative "default"

  module Configuration
    def self.extended(klass)
      super

      klass.class_eval do
        extend Dry::Configurable

        setting :access_token, default: Default.access_token
        setting :endpoint, default: Default.endpoint
        setting :middleware, default: Default.middleware
        setting :proxy, default: Default.proxy
        setting :user_agent, default: Default.user_agent
      end
    end
  end
end

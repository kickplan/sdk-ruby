# frozen_string_literal: true

require "dry/configurable"

module Kickplan
  require_relative "default"

  module Configuration
    def self.included(klass)
      klass.prepend Initializer
    end

    def self.extended(klass)
      klass.class_eval do
        extend Dry::Configurable

        setting :access_token, default: Default.access_token
        setting :adapter, default: Default.adapter
        setting :endpoint, default: Default.endpoint
        setting :middleware, default: Default.middleware
        setting :proxy, default: Default.proxy
        setting :user_agent, default: Default.user_agent
      end
    end

    module Initializer
      def initialize(...)
        extend Configuration
        super
      end
    end
  end
end

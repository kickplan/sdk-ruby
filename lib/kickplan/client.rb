# frozen_string_literal: true

require "forwardable"

module Kickplan
  require_relative "configuration"
  require_relative "resources"

  class Client < Module
    extend Forwardable

    attr_reader :semaphore

    delegate %i(get post put delete) => :connection

    def initialize
      extend Configuration

      # Use global configuration as client defaults
      config.update(Kickplan.config.values)

      # Clients are singletons, mutations should be thread-safe
      @semaphore = Mutex.new
    end

    def connection
      return @connection if defined?(@connection)

      semaphore.synchronize do
        @connection = Faraday::Connection.new(conn_options)
      end
    end

    private

    def conn_options
      {
        url: config.endpoint,
        proxy: config.proxy,
        builder: config.middleware,
        headers: {
          user_agent: config.user_agent
        }
      }
    end

    def const_missing(name)
      unless Resources.const_defined?(name)
        raise NameError, "uninitialized constant #{self}::#{name}"
      end

      semaphore.synchronize do
        Resources.const_get(name).new(self).tap do |resource|
          self.const_set(name, resource)
        end
      end
    end
  end
end

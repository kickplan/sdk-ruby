# frozen_string_literal: true

require "faraday"

module Kickplan
  require_relative "configuration"
  require_relative "resources"

  class Client < Module
    attr_reader :semaphore

    def initialize
      extend Configuration

      # Set defaults to global configuration
      config.update(Kickplan.config.values)

      # Clients are singletons and all mutations need
      # to be thread-safe.
      @semaphore = Mutex.new
    end

    def connection
      return @connection if defined?(@connection)

      semaphore.synchronize do
        @connection = Faraday::Connection.new(conn_options) do |conn|

        end
      end
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

    private

    def conn_options
      {}.tap do |options|
        options[:url] = config.endpoint
        options[:proxy] = config.proxy unless config.proxy.nil?
      end
    end
  end
end

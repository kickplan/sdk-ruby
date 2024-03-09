# frozen_string_literal: true

begin
  # Loading specific modules was added in 1.2
  require "concurrent/map"
rescue LoadError
  require "concurrent"
end

require "forwardable"

module Kickplan
  require_relative "kickplan/client"
  require_relative "kickplan/configuration"
  require_relative "kickplan/version"

  extend Configuration

  @_clients = Concurrent::Map.new

  class << self
    def client(name = :default)
      clients.fetch_or_store(name.to_s) { Client.new(name) }
    end
    alias_method :[], :client

    def clients
      @_clients
    end

    private

    def const_missing(name)
      client.const_get(name, false)
    end
  end
end

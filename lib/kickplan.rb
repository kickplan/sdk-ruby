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
  require_relative "kickplan/version"

  @_clients = Concurrent::Map.new

  class << self
    extend Forwardable

    delegate [:config, :configure] => :client

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

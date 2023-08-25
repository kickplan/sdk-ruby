# frozen_string_literal: true

begin
  # Versions >= 1.2
  require "concurrent/map"
rescue LoadError
  require "concurrent"
end

require "dry/core"

module Kickplan
  module Registry
    require_relative "client"

    extend Dry::Core::Container::Mixin

    register(:clients, memoize: true) { Concurrent::Map.new }

    def self.[](name)
      clients.fetch_or_store(name) { Client.new }
    end

    def self.clients
      resolve(:clients)
    end
  end
end

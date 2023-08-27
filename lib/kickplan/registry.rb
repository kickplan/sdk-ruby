# frozen_string_literal: true

begin
  # Loading specific modules was added in 1.2
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

    class << self
      def [](name)
        clients.fetch_or_store(name) { Client.new }
      end

      def clients
        resolve(:clients)
      end
    end
  end
end

# frozen_string_literal: true

module Kickplan
  require_relative "kickplan/configuration"
  require_relative "kickplan/registry"
  require_relative "kickplan/version"

  extend Configuration

  class << self
    def client(name = :default)
      Registry[name]
    end
    alias_method :[], :client

    def clients
      Registry.clients
    end

    private

    def const_missing(name)
      client.const_get(name)
    end
  end
end

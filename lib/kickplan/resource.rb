# frozen_string_literal: true

module Kickplan
  require_relative "adapter"
  require_relative "request"
  require_relative "schema"

  class Resource < Module
    extend Forwardable

    delegate %i(adapter) => :client

    attr_reader :client

    def initialize(client)
      @client = client
    end

    def inspect
      "#{client.inspect}::#{self.class.name.split("::").last}"
    end
    alias_method :to_s, :inspect
  end

  require_relative "resources/accounts"
  require_relative "resources/features"
  require_relative "resources/metrics"
end

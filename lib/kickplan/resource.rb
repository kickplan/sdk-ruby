# frozen_string_literal: true

module Kickplan
  require_relative "adapter"
  require_relative "response"

  class Resource < Module
    extend Forwardable

    delegate %i(adapter) => :client

    attr_reader :client

    def initialize(client)
      @client = client
    end
  end

  require_relative "resources/features"
end

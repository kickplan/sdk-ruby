# frozen_string_literal: true

module Kickplan
  require_relative "concurrency"
  require_relative "errors"

  class Adapter
    include Concurrency

    def self.for(config)
      adapter = Adapters[config.adapter] ||
        fail(Errors::Configuration, "unknown adapter `#{config.adapter}`")

      adapter.new(config)
    end

    attr_reader :config

    def initialize(config = {})
      @config = config
    end
  end
end

# frozen_string_literal: true

module Kickplan
  require_relative "adapters"
  require_relative "concurrency"
  require_relative "configuration"
  require_relative "resource"

  class Client < Module
    include Concurrency
    include Configuration

    attr_reader :name

    def initialize(name)
      @name = name.to_s

      # Use global configuration as client defaults
      config.update(Kickplan.config.values)
    end

    def adapter
      memoize { Adapter.for(config) }
    end

    def inspect
      "#<#{self.class.name}(#{name})>"
    end
    alias_method :to_s, :inspect

    def reset
      unset(:adapter)
    end

    private

    def const_missing(name)
      synchronize do
        Resources.const_get(name).new(self).tap do |resource|
          self.const_set(name, resource)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Kickplan
  require_relative "adapter"

  module Adapters
    @_registry = Concurrent::Map.new

    class << self
      def [](name)
        registry.get(name.to_s)
      end

      def register(name, klass)
        registry.put(name.to_s, klass)
      end

      def registry
        @_registry
      end
    end
  end

  require_relative "adapters/http"
  require_relative "adapters/memory"
end

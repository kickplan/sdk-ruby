# frozen_string_literal: true

module Kickplan
  module Concurrency
    def self.included(klass)
      klass.prepend Initializer
    end

    def memoize(name = caller_locations(1,1)[0].label, &block)
      name = ["@", name.to_s].join

      if instance_variable_defined?(name)
        return instance_variable_get(name)
      end

      synchronize { instance_variable_set(name, block.call) }
    end

    def synchronize(&block)
      @_semaphore.synchronize(&block)
    end

    module Initializer
      def initialize(...)
        @_semaphore = Mutex.new
        super
      end
    end
  end
end

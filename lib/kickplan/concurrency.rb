# frozen_string_literal: true

module Kickplan
  module Concurrency
    def self.included(klass)
      klass.prepend Initializer
    end

    def memoize(name = caller_locations(1,1)[0].label, &block)
      memo = memoization_variable(name)

      synchronize do
        if instance_variable_defined?(memo)
          instance_variable_get(memo)
        else
          instance_variable_set(memo, block.call)
        end
      end
    end

    def synchronize(&block)
      @_semaphore.synchronize(&block)
    end

    def unset(name)
      memo = memoization_variable(name)

      if instance_variable_defined?(memo)
        remove_instance_variable(memo)
      end
    end

    private

    def memoization_variable(name)
      ["@", name.to_s].join
    end

    module Initializer
      def initialize(...)
        @_semaphore = Mutex.new
        super
      end
    end
  end
end

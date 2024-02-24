# frozen_string_literal: true

module Kickplan
  module Resources
    class Metrics < Resource
      def decrement(key, value, context = nil)
        update("decrement", key, value, context)
      end

      def increment(key, value, context = nil)
        update("increment", key, value, context)
      end

      def set(key, value, context = nil)
        update("set", key, value, context)
      end

      def update(action, key, value, context = nil)
        if value.is_a?(Hash) && context.nil?
          value, context = 1, value
        end

        params = Requests::Metrics::Update.new(
          action: action,
          context: context,
          key: key,
          value: value
        )

        adapter.update_metric(params)
        true
      end
    end
  end
end

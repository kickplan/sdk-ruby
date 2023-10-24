# frozen_string_literal: true

module Kickplan
  module Resources
    class Metrics < Resource
      def set(key, value)
        params = Requests::EmitEvent.new(
          data: { value: value },
          subject: key,
          type: "com.kickplan.metrics.set"
        )

        adapter.emit_event(params)
      end

      def increment(key, value)
        params = Requests::EmitEvent.new(
          data: { value: value },
          subject: key,
          type: "com.kickplan.metrics.increment"
        )

        adapter.emit_event(params)
      end
    end
  end
end

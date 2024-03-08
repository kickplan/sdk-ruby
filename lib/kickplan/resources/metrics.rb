# frozen_string_literal: true

module Kickplan
  module Resources
    class Metrics < Resource
      def set(options = {})
        params = Requests::Metrics::Set.new(options)

        adapter.set_metric(params)
      end
    end
  end
end

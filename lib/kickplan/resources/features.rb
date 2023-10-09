# frozen_string_literal: true

module Kickplan
  module Resources
    class Features < Resource
      def resolve(...)
        Responses::Resolution.new(
          adapter.resolve(...)
        )
      end
    end
  end
end

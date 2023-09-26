# frozen_string_literal: true

module Kickplan
  require_relative "../responses/resolution"

  module Resources
    class Features < Resource
      def variant(key, params = {})
        response = client.post("features/#{key}", params)

        Responses::Resolution.new(response.body)
      end

      def variants(params = {})
        response = client.post("features", params)

        response.body.map do |record|
          Responses::Resolution.new(record)
        end
      end
    end
  end
end

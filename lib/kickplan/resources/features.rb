# frozen_string_literal: true

module Kickplan
  module Resources
    class Features < Resource
      # @deprecated
      def configure(key, options = {})
        params = Requests::Features::Configure.new(options.merge(key: key))
        adapter.configure_feature(params)
      end

      def resolve(key = nil, options = {})
        if key.nil? || key.is_a?(Hash)
          key, options = nil, key
        end

        params = Requests::Features::Resolve.new(options)

        response =
          if key.nil?
            adapter.resolve_features(params)
          else
            adapter.resolve_feature(key, params)
          end

        Schemas::Resolution.wrap(response)
      end
    end
  end
end

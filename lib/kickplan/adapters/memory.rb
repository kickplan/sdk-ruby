# frozen_string_literal: true

module Kickplan
  module Adapters
    class Memory < Adapter
      def configure_account(params)
        accounts.merge_pair(params.key, params) do |existing|
          existing.merge(params)
        end
        true
      end

      def configure_feature(params)
        features.put(params.key, params)
        true
      end

      def resolve_feature(key, params)
        feature = features.get(key) ||
          fail(ClientError, "Feature \"#{key}\" was not found")

        account = accounts.get(params.context&.account_key)
        variant = resolve_variant(feature, account)

        { key: key, value: feature.variants[variant] }.tap do |response|
          break response unless params.detailed

          response.merge!(
            metadata: { "name" => feature.name },
            variant: variant
          )
        end
      end

      def resolve_features(params)
        features.keys.map do |key|
          resolve_feature(key, params)
        end
      end

      def update_metric(params)
        lookup_key = [params.key, params.context.account_key].join(".")
        current_value = metrics[lookup_key] || 0

        new_value =
          case params.action
          when "set"
            params.value
          when "increment"
            current_value + params.value
          when "decrement"
            current_value - params.value
          end

        metrics[lookup_key] = new_value
      end

      # @api private
      def accounts
        memoize { Concurrent::Map.new }
      end

      # @api private
      def features
        memoize { Concurrent::Map.new }
      end

      # @api private
      def metrics
        memoize { Concurrent::Map.new }
      end

      private

      def resolve_variant(feature, account = nil)
        (account && account.overrides[feature.key]) || feature.default
      end
    end
  end

  Adapters.register(:memory, Adapters::Memory)
end

# frozen_string_literal: true

module Kickplan
  module Adapters
    class Memory < Adapter
      def create_account(params)
        accounts.compute(params.key) do |existing|
          unless existing.nil?
            fail(Errors::BadRequest, "Account \"#{params.key}\" already exists")
          end

          # @todo Add support for all fields
          fields = params.to_h.slice(:key, :name)
          Schemas::Account.new(fields)
        end
      end

      # @deprecated
      def configure_account(params)
        overrides.merge_pair(params.key, params) do |existing|
          existing.merge(params)
        end
      end

      def configure_feature(params)
        features.put(params.key, params)
        true
      end

      def resolve_feature(key, params)
        feature = features.get(key) ||
          fail(ClientError, "Feature \"#{key}\" was not found")

        account = overrides.get(params.context&.account_key)
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

      def flush_metrics
        true
      end

      def set_metric(params)
        metrics["#{params.key}.#{params.account_key}"] = params.value
        true
      end

      def update_account(key, params)
        accounts.compute(key) do |existing|
          if existing.nil?
            fail(Errors::NotFound, "Account \"#{key}\" not found")
          end

          # @todo Add support for all fields
          fields = params.to_h.slice(:name).merge(key: key)
          Schemas::Account.new(fields)
        end
      end

      def upsert_billable_object(params)
        true
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

      # @api private
      # @deprecated
      def overrides
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

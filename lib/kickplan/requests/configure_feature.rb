# frozen_string_literal: true

module Kickplan
  module Requests
    class ConfigureFeature < Request
      FeatureTypes = Types::String.default("boolean").
        enum("boolean", "integer", "object", "string")

      DefaultVariants = { "true" => true, "false" => false }.freeze

      attribute :key, Types::String
      attribute? :name, Types::String.optional
      attribute? :type, FeatureTypes
      attribute? :default, Types::String.default("false")
      attribute? :variants, Types::Hash.default(DefaultVariants)
    end
  end
end

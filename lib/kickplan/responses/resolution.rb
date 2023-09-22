# frozen_string_literal: true

module Kickplan
  require_relative "../response"

  module Responses
    class Resolution < Response
      attribute :key, Types::String
      attribute :value, Types::Any

      # Detailed resolution
      attribute? :error_code, Types::String.optional
      attribute? :error_message, Types::String.optional
      attribute? :metadata, Types::Hash.optional
      attribute? :reason, Types::String.optional
      attribute? :variant, Types::String.optional
    end
  end
end

# frozen_string_literal: true

require "securerandom"

module Kickplan
  module Requests
    class EmitEvent < Request
      attribute :data, Types::Hash
      attribute :subject, Types::String
      attribute :type, Types::String

      # Optional arguments
      attribute? :id, Types::String.default { SecureRandom.uuid }
      attribute? :source, Types::String.default("/i/dont/know")
      attribute? :spec_version, Types::String.default("1.0")
    end
  end
end

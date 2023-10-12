# frozen_string_literal: true

require "dry-struct"

module Kickplan
  require_relative "types"

  class Response < Dry::Struct
    transform_keys(&:to_sym)

    def self.wrap(attributes = {})
      if attributes.is_a? Hash
        new(attributes)
      else
        Array(attributes).map &method(:new)
      end
    end
  end

  require_relative "responses/resolution"
end

# frozen_string_literal: true

require "dry-struct"

module Kickplan
  require_relative "types"

  class Schema < Dry::Struct
    transform_keys(&:to_sym)

    def self.wrap(attributes = {})
      case attributes
      when Hash
        new(attributes)
      when Enumerable
        Array(attributes).map &method(:new)
      else
        attributes
      end
    end
  end

  require_relative "schemas/account"
  require_relative "schemas/billable_object"
  require_relative "schemas/resolution"
end

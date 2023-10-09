# frozen_string_literal: true

require "dry-struct"

module Kickplan
  require_relative "types"

  class Response < Dry::Struct
    transform_keys(&:to_sym)

    def self.new(attributes = nil, ...)
      if attributes.is_a? Array
        attributes.map &method(:new)
      else
        super
      end
    end
  end

  require_relative "responses/resolution"
end

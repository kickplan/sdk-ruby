# frozen_string_literal: true

require "dry-struct"

module Kickplan
  require_relative "types"

  class Response < Dry::Struct
    transform_keys(&:to_sym)
  end
end

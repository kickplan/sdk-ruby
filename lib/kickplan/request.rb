# frozen_string_literal: true

require "dry-struct"

module Kickplan
  require_relative "types"

  class Request < Dry::Struct
    transform_keys(&:to_sym)
    schema schema.strict
  end

  require_relative "requests/configure_account"
  require_relative "requests/configure_feature"
  require_relative "requests/resolve_feature"
end

# frozen_string_literal: true

require "dry-struct"

module Kickplan
  require_relative "types"

  class Request < Dry::Struct
    transform_keys(&:to_sym)
    schema schema.strict
  end

  require_relative "requests/accounts/create"
  require_relative "requests/accounts/update"
  require_relative "requests/features/resolve"
  require_relative "requests/metrics/update"

  # Deprecated
  require_relative "requests/accounts/configure"
  require_relative "requests/features/configure"
end

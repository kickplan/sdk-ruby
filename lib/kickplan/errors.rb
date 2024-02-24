# frozen_string_literal: true

module Kickplan
  Error = Class.new(StandardError)

  # Generic errors
  ClientError = Class.new(Error)
  HttpError = Class.new(Error)
  ServiceError = Class.new(Error)

  module Errors
    # Client errors
    Configuration = Class.new(ClientError)

    # Service errors
    BadRequest = Class.new(ServiceError)
    NotAuthorized = Class.new(ServiceError)
    NotFound = Class.new(ServiceError)
  end
end

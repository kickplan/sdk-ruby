# frozen_string_literal: true

module Kickplan
  Error = Class.new(StandardError)

  # Generic errors
  HttpError = Class.new(Error)
  ServiceError = Class.new(HttpError)
  ServerError = Class.new(HttpError)

  module Errors
    # Service errors
    BadRequest = Class.new(ServiceError)
    NotAuthorized = Class.new(ServiceError)
    NotFound = Class.new(ServiceError)
  end
end
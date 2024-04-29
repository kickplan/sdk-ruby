# frozen_string_literal: true

module Kickplan
  require_relative "../errors"

  module Middleware
    require_relative "base"

    class RaiseError < Base
      def on_complete(env)
        response = env.response

        case response.status
        when 400
          fail Errors::BadRequest, response.body
        when 403
          fail Errors::NotAuthorized, response.body
        when 404
          fail Errors::NotFound, response.body
        when (400..499)
          fail ServiceError, response.body
        when (500..599)
          fail ServerError, response.body
        end
      end
    end
  end
end

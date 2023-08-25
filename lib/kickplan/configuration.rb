# frozen_string_literal: true

require "dry/configurable"

module Kickplan
  module Configuration
    def self.extended(klass)
      klass.class_eval do
        extend Dry::Configurable

        setting :proxy
        setting :endpoint, default: "foo"
        setting :token, default: "bar"
      end
    end
  end
end

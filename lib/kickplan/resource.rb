# frozen_string_literal: true

module Kickplan
  class Resource < Module
    attr_reader :client

    def initialize(client)
      @client = client
    end
  end
end

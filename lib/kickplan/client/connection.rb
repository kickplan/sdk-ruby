# frozen_string_literal: true

require "faraday"

module Kickplan
  class Client::Connection
    REQUESTS = %i(get post put delete).freeze

    attr_reader :config, :semaphore

    def initialize(config)
      @config = config
      @semaphore = Mutex.new
    end

    def agent
      return @agent if defined?(@agent)

      semaphore.synchronize do
        @agent = Faraday::Connection.new(
          url: config.endpoint,
          proxy: config.proxy,
          builder: config.middleware,
          headers: {
            user_agent: config.user_agent
          }
        )
      end
    end

    REQUESTS.each do |method|
      define_method(method) do |path, params={}, &block|
        request(method, path, params, &block)
      end
    end

    private

    def request(method, path, params, &block)
      agent.public_send(method, path, params, &block)
    end
  end
end

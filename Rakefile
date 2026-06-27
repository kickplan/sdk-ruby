# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

begin
  require "pact_broker/client/tasks"

  PactBroker::Client::PublicationTask.new do |task|
    task.consumer_version = `git rev-parse --short HEAD`.strip
    task.pact_broker_base_url = ENV.fetch("PACT_BROKER_BASE_URL", "http://localhost:9292")
    task.pact_broker_basic_auth = {
      username: ENV.fetch("PACT_BROKER_USERNAME", "pact"),
      password: ENV.fetch("PACT_BROKER_PASSWORD", "pact")
    }
    task.branch = `git rev-parse --abbrev-ref HEAD`.strip
    task.tag_with_git_branch = true
  end
rescue LoadError
  # pact_broker-client not available outside dev
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe Kickplan do
  it "has a default client" do
    expect(Kickplan.client).to be Kickplan.client(:default)
  end

  it "has a default config" do
    expect(Kickplan.config).to be Kickplan[:default].config
  end

  it "has default resources" do
    expect(Kickplan::Features).to be Kickplan[:default]::Features
  end

  it "has a version number" do
    expect(Kickplan::VERSION).not_to be nil
  end
end

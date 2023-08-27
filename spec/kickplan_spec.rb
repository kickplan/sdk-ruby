# frozen_string_literal: true

require "spec_helper"

RSpec.describe Kickplan do
  it "has a version number" do
    expect(Kickplan::VERSION).not_to be nil
  end
end

# frozen_string_literal: true

RSpec.describe Semversion do
  it "has a version number" do
    expect(Semversion::VERSION).not_to be nil
  end
end

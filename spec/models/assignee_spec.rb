# frozen_string_literal: true

require "rails_helper"

RSpec.describe Assignee, type: :model do
  it "has a valid factory" do
    expect(build(:assignee)).to be_valid
  end
end

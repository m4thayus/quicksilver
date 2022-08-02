# frozen_string_literal: true

require "rails_helper"

RSpec.describe Task, type: :model do
  it "has a valid factory" do
    expect(build(:task)).to be_valid
  end
end

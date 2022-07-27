# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  context "when password does not match confirmation" do
    it "is invalid" do
      expect(build(:user, password_confirmation: "wrong")).to_not be_valid
    end
  end
end

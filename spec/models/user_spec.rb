# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  subject { create(:user) }

  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  context "when password does not match confirmation" do
    it "is invalid" do
      expect(build(:user, password_confirmation: "wrong")).to_not be_valid
    end
  end

  context "when user is an administrator" do
    subject { create(:admin_user) }

    it "has a valid factory" do
      expect(build(:admin_user)).to be_valid
    end

    it { is_expected.to be_admin }
  end

  context "when user is an engineer" do
    subject { build(:engineer_user) }

    it "has a valid factory" do
      expect(build(:engineer_user)).to be_valid
    end

    it { is_expected.to be_engineer }
  end
end

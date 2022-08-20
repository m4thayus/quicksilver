# frozen_string_literal: true

require "rails_helper"

RSpec.describe Task, type: :model do
  it "has a valid factory" do
    expect(build(:task)).to be_valid
  end

  it "can be owned by user" do
    expect(build(:task, owner: create(:user))).to be_valid
  end

  it "has an active scope" do
    create(:task, completed_at: nil)
    expect(described_class.active.length).to eq(1)
  end

  it "has a recently completed at scope" do
    create(:task, completed_at: 3.days.ago)
    expect(described_class.recently_completed.length).to eq(1)
  end
end

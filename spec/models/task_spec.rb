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
    expect(described_class.active.count).to eq(1)
  end

  it "has a recently completed at scope" do
    create(:task, completed_at: 3.weeks.ago)
    expect(described_class.recently_completed.count).to eq(1)
  end

  it "allows valid sizes" do
    expect(build(:task, size: "small")).to be_valid
  end

  it "does not allow invalid sizes" do
    expect(build(:task, size: "invalid")).not_to be_valid
  end

  it "uses the custom size error message" do
    expect { create(:task, size: "invalid") }.to raise_error(ActiveRecord::RecordInvalid, /"invalid"/)
  end
end

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
    create(:task, completed_at: 3.days.ago)
    expect(described_class.recently_completed.count).to eq(1)
  end

  describe "approved property" do
    subject { create(:task) }

    it "instantiates to false" do
      expect(subject.approved).to be false
    end

    context "when board changes" do
      let(:previously_approved_task) { create(:task, approved: true) }

      before do
        previously_approved_task.update(board: create(:wishlist))
      end

      it "resets approved to false" do
        expect(previously_approved_task.approved).to be(false)
      end
    end
  end
end

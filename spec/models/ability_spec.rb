# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability, type: :model do
  subject { described_class.new(user) }

  let!(:wishlist) { create(:wishlist) }
  let!(:suggestions) { create(:suggestions) }
  let(:user) { nil }

  it "has serializable permissions" do
    expect(subject.permissions).to include :can, :cannot
  end

  context "when the user is a user" do
    it { is_expected.to_not be_able_to(:read, :all) }
  end

  context "when the user is a guest" do
    let(:user) { create(:guest_user) }
    let(:task) { create(:task) }
    let(:suggestions_task) { create(:task, board: suggestions) }
    let(:wishlist_task) { create(:task, board: wishlist) }

    it { is_expected.to be_able_to(:manage, suggestions_task) }

    it "cannot edit the approved field on a suggestions task" do
      expect(subject).to_not be_able_to(:update, suggestions_task, :approved)
    end

    it "cannot manage wishlist tasks" do
      expect(subject).to_not be_able_to(:manage, wishlist_task)
    end

    it "cannot manage non-wishlist tasks" do
      expect(subject).to_not be_able_to(:manage, task)
    end
  end

  context "when the user is a member" do
    let(:user) { create(:member_user) }
    let(:other_user) { create(:engineer_user) }
    let(:task) { create(:task) }
    let(:wishlist_task) { create(:task, board: wishlist) }
    let(:suggestions_task) { create(:task, board: suggestions) }

    it { expect(task.board).to be_nil }
    it { is_expected.to be_able_to(:read, user) }
    it { is_expected.to be_able_to(:read, other_user) }
    it { is_expected.to be_able_to(:read, task) }

    it "can view the list of wishlist tasks" do
      expect(subject).to be_able_to(:index, wishlist)
    end

    it "can manage wishlist tasks" do
      expect(subject).to be_able_to(:manage, wishlist_task)
    end

    it "cannot manage non-wishlist tasks" do
      expect(subject).to_not be_able_to(:manage, task)
    end

    it "cannot create non-wishlist tasks" do
      expect(subject).to_not be_able_to(:create, build(:task))
    end

    it "cannot edit date fields on wishlist tasks" do
      expect(subject).to_not be_able_to(:update, task, :created_at)
    end

    it "can edit description on non-wishlist tasks" do
      expect(subject).to be_able_to(:update, task, :description)
    end

    it "can edit the approved field on a wishlist" do
      expect(subject).to be_able_to(:update, wishlist_task, :approved)
    end

    it "can edit the approved field on suggestions tasks" do
      expect(subject).to be_able_to(:update, suggestions_task, :approved)
    end

    it "cannot edit the approved field on a non-wishlist" do
      expect(subject).to_not be_able_to(:update, task, :approved)
    end
  end

  context "when the user is an engineer" do
    let(:user) { create(:engineer_user) }

    it { is_expected.to be_able_to(:read, :all) }
    it { is_expected.to be_able_to(:manage, Task) }
    it { is_expected.to be_able_to(:manage, Board) }
  end

  context "when then user is an admin" do
    let(:user) { create(:admin_user) }

    it { is_expected.to be_able_to(:manage, :all) }
  end
end

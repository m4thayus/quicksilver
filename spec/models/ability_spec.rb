# frozen_string_literal: true

require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability, type: :model do
  subject { described_class.new(user) }

  let!(:wishlist) { create(:wishlist) }
  let(:user) { nil }

  it "has serializable permissions" do
    expect(subject.permissions).to include :can, :cannot
  end

  context "when the user is a guest" do
    it { is_expected.to_not be_able_to(:read, :all) }
  end

  context "when the user is a member" do
    let(:user) { create(:member_user) }
    let(:other_user) { create(:engineer_user) }
    let(:task) { create(:task) }
    let(:wishlist_task) { create(:task, board: wishlist) }

    it { expect(task.board).to be_nil }

    it { is_expected.to be_able_to(:index, wishlist) }
    it { is_expected.to be_able_to(:read, user) }
    it { is_expected.to be_able_to(:read, other_user) }
    it { is_expected.to be_able_to(:read, task) }
    it { is_expected.to be_able_to(:manage, wishlist_task) }
    it { is_expected.to be_able_to(:create, build(:task, board: wishlist)) }
    it { is_expected.to be_able_to(:update, wishlist_task, :title) }
    it { is_expected.to be_able_to(:update, wishlist_task, :owner_id) }
    it { is_expected.to be_able_to(:update, wishlist_task, :description) }
    it { is_expected.to be_able_to(:update, wishlist_task, :approved) }
    it { is_expected.to_not be_able_to(:manage, task) }
    it { is_expected.to_not be_able_to(:create, build(:task), :title) }
    it { is_expected.to_not be_able_to(:create, build(:task), :owner_id) }
    it { is_expected.to_not be_able_to(:create, build(:task), :description) }
    it { is_expected.to_not be_able_to(:create, build(:task), :started_at) }
    it { is_expected.to_not be_able_to(:create, build(:task), :expected_at) }
    it { is_expected.to_not be_able_to(:create, build(:task), :board_id) }
    it { is_expected.to_not be_able_to(:create, build(:task), :completed_at) }
    it { is_expected.to_not be_able_to(:create, build(:task), :approved) }
    it { is_expected.to_not be_able_to(:update, build(:task), :started_at) }
    it { is_expected.to_not be_able_to(:update, build(:task), :expected_at) }
    it { is_expected.to_not be_able_to(:update, build(:task), :board_id) }
    it { is_expected.to_not be_able_to(:update, build(:task), :completed_at) }
    it { is_expected.to_not be_able_to(:update, build(:task), :approved) }
    it { is_expected.to_not be_able_to(:create, build(:task, board: wishlist), :started_at) }
    it { is_expected.to_not be_able_to(:create, build(:task, board: wishlist), :expected_at) }
    it { is_expected.to_not be_able_to(:create, build(:task, board: wishlist), :completed_at) }
    it { is_expected.to_not be_able_to(:create, build(:task, board: wishlist), :board_id) }
    it { is_expected.to_not be_able_to(:update, wishlist_task, :started_at) }
    it { is_expected.to_not be_able_to(:update, wishlist_task, :expected_at) }
    it { is_expected.to_not be_able_to(:update, wishlist_task, :completed_at) }
    it { is_expected.to_not be_able_to(:update, wishlist_task, :board_id) }
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

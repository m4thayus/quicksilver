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
    it { is_expected.to_not be_able_to(:manage, task) }
    it { is_expected.to be_able_to(:create, Task, build(:task, board: wishlist)) }
    it { is_expected.to be_able_to(:manage, wishlist_task) }
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

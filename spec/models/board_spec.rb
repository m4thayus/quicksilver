# frozen_string_literal: true

require "rails_helper"

RSpec.describe Board, type: :model do
  subject { create(:board) }

  it "has a valid factory" do
    expect(build(:board)).to be_valid
  end

  it "requires a name" do
    expect(build(:board, name: nil)).to_not be_valid
  end

  it "requires a unique name" do
    expect(build(:board, name: subject.name)).to_not be_valid
  end

  it "paramterizes name before validation" do
    expect(create(:board, name: "Board Name").name).to eql("Board Name".parameterize)
  end
end

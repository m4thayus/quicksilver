# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/index", type: :view do
  let(:users) do
    [0..2].map { create(:user) }
  end

  before do
    assign(:users, users)
  end

  it "renders the first user" do
    render
    expect(rendered).to match(/#{users.first.name}/)
  end

  it "renders the last user" do
    render
    expect(rendered).to match(/#{users.last.name}/)
  end
end

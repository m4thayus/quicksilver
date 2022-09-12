# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/index", type: :view do
  let(:users) { create_list(:user, 3) }

  before do
    assign(:users, users)
  end

  describe "the first user" do
    it "renders the name" do
      render
      expect(rendered).to match(/#{users.first.name}/)
    end

    it "renders the email" do
      render
      expect(rendered).to match(/#{users.first.email}/)
    end
  end

  describe "the last user" do
    it "renders the name" do
      render
      expect(rendered).to match(/#{users.last.name}/)
    end

    it "renders the email" do
      render
      expect(rendered).to match(/#{users.last.email}/)
    end
  end
end

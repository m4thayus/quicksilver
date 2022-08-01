# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/new", type: :view do
  describe "the new user form" do
    it "renders a name input" do
      render
      expect(rendered).to match(/input.*name="user\[name\]"/)
    end

    it "renders an email input" do
      render
      expect(rendered).to match(/input.*name="user\[email\]"/)
    end

    it "renders a password input" do
      render
      expect(rendered).to match(/input.*name="user\[password\]"/)
    end

    it "renders a password confirmation input" do
      render
      expect(rendered).to match(/input.*name="user\[password_confirmation\]"/)
    end
  end
end

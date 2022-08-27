# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Login", type: :feature do
  describe "Admin users" do
    let!(:user) { create(:admin_user) }

    it "ends up at the tasks page" do
      login_as user

      expect(page).to have_current_path tasks_path
    end
  end

  describe "Engineers" do
    let!(:user) { create(:engineer_user) }

    it "ends up at the tasks page" do
      login_as user

      expect(page).to have_current_path tasks_path
    end
  end

  describe "Guest users" do
    let!(:user) { create(:user) }

    it "ends up at the tasks page" do
      login_as user

      aggregate_failures("error response") do
        expect(page).to have_text "You are not authorized"
        expect(page.status_code).to eq 401
      end
    end

    it "fails on bad passwords", :aggregate_failures do
      login_as user, password: "wrong"

      expect(page).to have_text "Login failed"
      expect(page.status_code).to eq 401
    end

    it "logs out" do
      login_as user
      logout

      expect(page).to have_current_path login_path
    end
  end

  describe "Unknown users" do
    it "unknown email addresses fail", :aggregate_failures do
      login_as "unknown@example.com", password: "password"

      expect(page.status_code).to eq 401
      expect(page).to have_text "Login failed"
    end
  end
end

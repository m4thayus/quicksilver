# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Task List", type: :feature do
  before do
    login_as :engineer_user
  end

  context "when visiting index of tasks without board" do
    before do
      create_list(:task, 3, completed_at: nil)
      create_list(:task, 3, completed_at: 3.days.ago)
    end

    it "shows all the tasks" do
      visit tasks_path

      expect(page.all("tr").size).to eq 6
    end

    it "shows the active tasks" do
      visit tasks_path

      expect(page.all("table:first-of-type tr").size).to eq 3
    end

    it "shows the recently completed tasks" do
      visit tasks_path

      expect(page.all("table:last-of-type tr").size).to eq 3
    end

    it "shows a column for reviewed tasks" do
      visit tasks_path

      expect(page).to have_text "Reviewed"
    end
  end

  context "when visiting wishlist board" do
    let(:wishlist) { create(:wishlist) }

    before do
      create_list(:task, 3, board: wishlist)
    end

    it "shows all the wishlist tasks" do
      visit board_tasks_path(wishlist)

      expect(page.all("tr").size).to eq 3
    end

    it "shows a column for approved tasks" do
      visit board_tasks_path(wishlist)

      expect(page).to have_text "Approved"
    end
  end
end

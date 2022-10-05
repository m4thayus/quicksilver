# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Task List", type: :feature do
  let!(:boardless_list) { create_list(:task, 3, title: "Boardless Task", completed_at: nil) }

  before do
    login_as :engineer_user
  end

  context "when visiting index of tasks without board" do
    before do
      create_list(:task, 3, completed_at: 3.days.ago)
      visit tasks_path
    end

    it "shows all the tasks" do
      expect(page.all("tr").size).to eq 6
    end

    it "shows the active tasks" do
      expect(page.all("table:first-of-type tr").size).to eq 3
    end

    it "shows the recently completed tasks" do
      expect(page.all("table:last-of-type tr").size).to eq 3
    end

    it "shows a column for reviewed tasks" do
      expect(page).to have_text "Reviewed"
    end

    it "shows tasks without a board" do
      expect(page).to have_text boardless_list.first.title
    end
  end

  context "when visiting wishlist board" do
    let(:wishlist) { create(:wishlist) }
    let!(:wishlist_list) { create_list(:task, 3, title: "Wishlist Task", board: wishlist) }

    before do
      visit board_tasks_path(wishlist)
    end

    it "shows all the wishlist tasks" do
      expect(page.all("tr").size).to eq 3
    end

    it "shows a column for approved tasks" do
      expect(page).to have_text "Approved"
    end

    it "shows tasks belonging to the wishlist board" do
      expect(page).to have_text wishlist_list.first.title
    end

    it "does not show tasks that don't belong to the wishlist board" do
      expect(page).to_not have_text boardless_list.first.title
    end
  end
end

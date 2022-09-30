# frozen_string_literal: true

require "rails_helper"

RSpec.describe Board, type: :feature do
  let(:wishlist_board) { create(:wishlist) }

  before do
    create(:task, board: wishlist_board)
  end

  context "when allowed to promote" do
    let(:wishlist_board) { create(:wishlist) }

    before do
      login_as :engineer_user
      visit "/boards/#{wishlist_board.name}/tasks"
    end

    it "shows buttons for promotion of wishlist" do
      expect(page).to have_button "Promote"
    end

    context "when promote button is clicked" do
      let(:task_to_approve) { create(:task, title: "My New Task") }

      before do
        task_to_approve.approved = true
      end

      it "clears board association" do
        click_button "Promote"

        expect(task_to_approve.approved).to be_nil
      end

      it "navigates to task list" do
        click_button "Promote"

        expect(page).to have_current_path(tasks_path)
      end

      it "promoted task now appears on the task board" do
        click_button "Promote"

        expect(page).to have_text("My New Task")
      end
    end
  end

  context "when not allowed to promote" do
    before do
      login_as :member_user
      visit "/boards/#{wishlist_board.name}/tasks"
    end

    it "shows buttons for promotion of wishlist" do
      expect(page).to_not have_button "Promote"
    end
  end
end

# frozen_string_literal: true

RSpec.describe Board, type: :feature do
  context "when allowed to promote" do
    let(:wishlist_board) { create(:wishlist) }

    before do
      login_as :engineer_user
      create(:task, board: wishlist_board)
      visit "/boards/#{wishlist_board.name}/tasks"
    end

    it "shows buttons for promotion of wishlist" do
      expect(page).to have_button "Promote"
    end

    context "when promote button is clicked" do
      xit "clears board association"
      xit "navigates to task list"
      xit "promoted task now appears on the task board"
    end
  end
end

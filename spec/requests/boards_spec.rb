# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Boards", type: :request, user: :admin do
  describe "GET /boards" do
    it "is successful" do
      get boards_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /board/:id" do
    it "is successful" do
      get board_path(create(:board))
      expect(response).to have_http_status(:success)
    end
  end
end

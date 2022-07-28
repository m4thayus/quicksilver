# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/users"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/users/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "returns http success" do
      post "/users"
      expect(response).to have_http_status(:success)
    end
  end
end

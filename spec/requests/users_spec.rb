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
    subject { post "/users", params: { user: attributes_for(:user) } }

    it "returns http success" do
      subject
      expect(response).to have_http_status(:created)
    end

    it "creates a new user" do
      expect { subject }.to change { User.count }.by(1)
    end
  end
end

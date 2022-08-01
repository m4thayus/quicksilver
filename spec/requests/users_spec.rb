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

  describe "POST /login" do
    let(:current_user) { create(:user) }

    context "when password is correct" do
      subject { post "/login", params: { user: { email: current_user.email, password: current_user.password } } }

      it "redirects to users#index" do
        subject
        expect(response).to redirect_to(users_path)
      end

      it "sets the current user in the session" do
        subject
        expect(session).to include :current_user
      end
    end

    context "when password is wrong" do
      subject { post "/login", params: { user: { email: current_user.email, password: "wrong" } } }

      it "redirects to users#index" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end

      it "sets the current user in the session" do
        subject
        expect(session).to_not include :current_user
      end
    end
  end

  describe "DELETE /logout" do
    subject { delete "/logout" }

    let(:current_user) { create(:user) }

    before do
      post "/login", params: { user: { email: current_user.email, password: current_user.password } }
    end

    it "redirects to users#index" do
      subject
      expect(response).to redirect_to(users_path)
    end

    it "clears the session" do
      expect { subject }.to(change { session[:current_user] })
    end
  end
end

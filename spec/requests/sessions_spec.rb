# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "is successful" do
      get "/login"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /login" do
    let(:current_user) { create(:user) }

    context "when password is correct" do
      subject { post "/login", params: { user: UserHelper.credentials(current_user) } }

      it "redirects to tasks list" do
        subject
        expect(response).to redirect_to(tasks_path)
      end

      it "sets the current user in the session" do
        subject
        expect(session).to include :current_user
      end
    end

    context "when password is wrong" do
      subject { post "/login", params: { user: UserHelper.credentials(current_user, "wrong") } }

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

  describe "GET /logout" do
    subject { get "/logout" }

    let(:current_user) { create(:user) }

    before do
      post "/login", params: { user: UserHelper.credentials(current_user) }
    end

    it "redirects to users#index" do
      subject
      expect(response).to redirect_to(login_path)
    end

    it "clears the session" do
      expect { subject }.to(change { session[:current_user] })
    end
  end
end

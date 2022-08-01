# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    current_user = User.find_by(email: login_params[:email]).authenticate(login_params[:password])
    if current_user.present?
      session[:current_user] = current_user.email
      redirect_to users_path
    else
      head :unauthorized
    end
  end

  def destroy
    reset_session
    redirect_to users_path
  end

  private

  def login_params
    @login_params ||= params.require(:user).permit %i[email password]
  end
end

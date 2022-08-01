# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def create
    if User.create(user_params)
      head :created
    else
      head :bad_request
    end
  end

  def login
    current_user = User.find_by(email: login_params[:email]).authenticate(login_params[:password])
    if current_user.present?
      session[:current_user] = current_user.email
      redirect_to users_path
    else
      head :unauthorized
    end
  end

  def logout
    reset_session
    redirect_to users_path
  end

  private

  def user_params
    @user_params ||= params.require(:user).permit %i[email name password password_confirmation]
  end

  def login_params
    @login_params ||= params.require(:user).permit %i[email password]
  end
end

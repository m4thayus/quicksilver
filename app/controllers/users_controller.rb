# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authorize, only: %i[index]

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

  private

  def user_params
    @user_params ||= params.require(:user).permit %i[email name password password_confirmation]
  end

  def authorize
    return if can? :read, User

    redirect_to login_path
  end
end

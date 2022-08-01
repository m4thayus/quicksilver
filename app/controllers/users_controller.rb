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

  private

  def user_params
    params.require(:user).permit %i[email name password password_confirmation]
  end
end

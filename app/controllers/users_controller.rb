# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authorize, only: %i[index]
  before_action :set_user, only: %i[edit update]

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

  def edit
    return if can? :edit, @user

    flash[:notice] = "You do not have permission to edit that user!"
    redirect_to users_path
  end

  def update
    return redirect_to users_path unless can? :update, @user

    if @user.update(user_params)
      redirect_to users_path
    else
      head :bad_request
    end
  end

  private

  def user_params
    @user_params ||= params.require(:user).permit %i[email name password password_confirmation]
  end

  def set_user
    @user ||= User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def authorize
    return if can? :read, User

    redirect_to login_path
  end
end

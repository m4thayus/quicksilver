# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def current_user
    @current_user ||= User.find_by(email: session[:current_user])
  end

  rescue_from CanCan::AccessDenied do |exception|
    @message = exception.message
    render "unauthorized", status: :unauthorized
  end
end

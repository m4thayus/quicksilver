# frozen_string_literal: true

class BoardsController < ApplicationController
  before_action :authorize
  before_action :set_board, only: :show

  def index
    @boards = Board.all
  end

  def show; end

  private

  def set_board
    @board = Board.find(params[:id])
  end

  def authorize
    return if can? :read, Board

    redirect_to login_path
  end
end

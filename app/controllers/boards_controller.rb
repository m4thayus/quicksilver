# frozen_string_literal: true

class BoardsController < ApplicationController
  before_action :set_board, only: %i[show]
  load_and_authorize_resource

  def show; end

  private

  def set_board
    @board = Board.find_by(name: params[:name])
  end
end

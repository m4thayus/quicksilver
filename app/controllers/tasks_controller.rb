# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_board
  load_and_authorize_resource except: :index
  before_action :associate_board

  def index
    board_tasks = Task.where(board: @board)
    @active_tasks = board_tasks.active
    @recently_completed_tasks = board_tasks.recently_completed
    authorize! :index, Task
  rescue CanCan::AccessDenied
    redirect_to login_path
  end

  def create
    @task.board = @board
    if @task.save
      redirect_to board_path
    else
      head :bad_request
    end
  end

  def update
    if @task.update(task_params)
      redirect_to board_path
    else
      head :bad_request
    end
  end

  def destroy
    @task.destroy
    redirect_to board_path
  end

  private

  def set_board
    @board = Board.find_by(name: params[:board_name]) if params[:board_name].present?
  end

  def associate_board
    @task.board = @board if @task
  end

  def task_params
    @task_params ||= params.require(:task).permit(:title, :description, :owner_id, :size, :started_at, :expected_at, :completed_at)
  end

  def board_path
    if @task.board.present?
      board_tasks_path(@task.board)
    else
      tasks_path
    end
  end
end

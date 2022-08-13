# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :authorize
  before_action :set_board
  before_action :set_task, except: %i[index new create]

  def index
    @tasks = Task.where(board: @board)
  end

  def show; end

  def new
    return if can? :new, Task.new(board: @board)

    flash[:notice] = "You do not have permission to create tasks!"
    redirect_to_tasks_path
  end

  def create
    task = Task.new(owner: task_owner, board: @board, **task_params)
    return redirect_to_tasks_path unless can? :create, task

    if task.save
      redirect_to_tasks_path
    else
      head :bad_request
    end
  end

  def edit
    return if can? :edit, @task

    flash[:notice] = "You do not have permission to edit that task!"
    redirect_to_tasks_path
  end

  def update
    return redirect_to_tasks_path unless can? :update, @task

    if @task.update(owner: task_owner, board: @board, **task_params)
      redirect_to_tasks_path
    else
      head :bad_request
    end
  end

  def destroy
    if can? :destroy, @task
      @task.destroy
    else
      flash[:notice] = "You do not have permission to destroy that task!"
    end
    redirect_to_tasks_path
  end

  private

  def set_board
    @board = Board.find(params[:board_id]) if params[:board_id].present?
  rescue ActiveRecord::RecordNotFound
    @board = nil
  end

  def set_task
    @task = Task.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def task_params
    @task_params ||= params.require(:task).permit :title, :description, :started_at, :expected_at, :completed_at, owner: [:email]
  end

  def task_owner
    @task_owner ||= User.find_by email: begin
                                          owner_email = task_params.dig(:owner, :email)
                                          task_params.delete(:owner)
                                          owner_email
                                        end
  end

  def authorize
    return if can? :read, Task

    redirect_to login_path
  end

  def redirect_to_tasks_path
    if @board.present?
      redirect_to board_tasks_path(@board)
    else
      redirect_to tasks_path
    end
  end
end

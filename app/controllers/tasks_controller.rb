# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :authorize
  before_action :set_task, except: %i[index new create]

  def index
    @tasks = Task.all
  end

  def show; end

  def new; end

  def create
    task = Task.new(task_params)
    if task.save
      redirect_to task_path(task)
    else
      head :bad_request
    end
  end

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to task_path(@task)
    else
      head :bad_request
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path
  end

  private

  def set_task
    @task = Task.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def task_params
    @task_params ||= params.require(:task).permit %i[title description]
  end

  def authorize
    return if can? :read, Task

    redirect_to login_path
  end
end

# frozen_string_literal: true

class SearchesController < ApplicationController
  def show
    authorize! :search, Task
    query = "%#{search_params[:q]}%"
    @tasks = Task.where(completed_at: nil)
                 .where("title LIKE ?", query)
                 .or Task.where(completed_at: nil)
                         .where("description LIKE ?", query)
  end

  def search_params
    params.permit(:q)
  end
end

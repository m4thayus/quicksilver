# frozen_string_literal: true

class AddPointsToTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :points, :integer
  end
end

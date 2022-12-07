# frozen_string_literal: true

class AddPointEstimateToTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :point_estimate, :integer
  end
end

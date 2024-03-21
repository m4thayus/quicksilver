# frozen_string_literal: true

class AddCriticalToTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :critical, :boolean, default: false
  end
end

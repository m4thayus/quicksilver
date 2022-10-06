# frozen_string_literal: true

class AddSizeToTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :size, :string, null: true
  end
end

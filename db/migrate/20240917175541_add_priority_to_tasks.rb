# frozen_string_literal: true

class AddPriorityToTasks < ActiveRecord::Migration[7.0]
  # rubocop:disable Rails/SkipsModelValidations
  def up
    add_column :tasks, :priority, :integer, default: 0, null: false
    Task.where(critical: false).update_all(priority: 3)
    Task.where(critical: true).update_all(priority: 4)
    remove_column :tasks, :critical, :boolean
  end

  def down
    add_column :tasks, :critical, :boolean, default: false, null: false
    Task.where("priority > ?", 3).update_all(critical: true)
    Task.where("priority <= ?", 3).update_all(critical: false)
    remove_column :tasks, :priority, :integer
  end
  # rubocop:enable Rails/SkipsModelValidations
end

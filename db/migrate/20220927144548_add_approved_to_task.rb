# frozen_string_literal: true

class AddApprovedToTask < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :approved, :boolean
  end
end

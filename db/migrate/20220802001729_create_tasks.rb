# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.date :started_at
      t.date :expected_at
      t.date :completed_at
      t.references :owner

      t.timestamps
    end
  end
end

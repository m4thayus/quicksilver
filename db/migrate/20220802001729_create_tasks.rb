# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :status
      t.text :description
      t.datetime :started_at
      t.datetime :expected_at
      t.datetime :completed_at
      t.references :owner

      t.timestamps
    end
  end
end

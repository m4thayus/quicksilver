# frozen_string_literal: true

class CreateBoards < ActiveRecord::Migration[7.0]
  def change
    create_table :boards do |t|
      t.string :name, index: { unique: true }
      t.text :description

      t.timestamps
    end

    add_reference :tasks, :board

    up_only do
      Board.create(name: "wishlist", description: "A list of possible future tasks")
    end
  end
end

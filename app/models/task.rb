# frozen_string_literal: true

class Task < ApplicationRecord
  has_many :assignees
  has_many :users, through: :assignees
end

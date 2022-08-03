# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :owner, class_name: "User", optional: true

  validates :title, presence: true
end

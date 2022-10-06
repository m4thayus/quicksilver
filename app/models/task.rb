# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :board, optional: true
  belongs_to :owner, class_name: "User", optional: true
  before_save :update_approved

  validates :title, presence: true

  scope :active, -> { where(completed_at: nil) }
  scope :recently_completed, -> { where("completed_at > ?", 1.week.ago) }

  private

  def update_approved
    self.approved = false if board_changed?
  end
end

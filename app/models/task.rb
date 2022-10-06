# frozen_string_literal: true

class Task < ApplicationRecord
  SIZES = %w[small medium large].freeze

  belongs_to :board, optional: true
  belongs_to :owner, class_name: "User", optional: true

  before_validation :nillify_size
  before_save :update_approved

  validates :title, presence: true
  validates :size, inclusion: { in: SIZES }, allow_nil: true

  scope :active, -> { where(completed_at: nil) }
  scope :recently_completed, -> { where("completed_at > ?", 1.week.ago) }

  private

  def nillify_size
    self.size = nil if size&.blank? # rubocop:disable Lint/SafeNavigationWithBlank
  end

  def update_approved
    self.approved = false if board_changed?
  end
end

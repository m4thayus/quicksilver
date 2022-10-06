# frozen_string_literal: true

class Task < ApplicationRecord
  SIZES = %w[small medium large].freeze
  before_validation :nillify_size

  belongs_to :board, optional: true
  belongs_to :owner, class_name: "User", optional: true

  validates :title, presence: true
  validates :size, inclusion: { in: SIZES }, allow_nil: true

  scope :active, -> { where(completed_at: nil) }
  scope :recently_completed, -> { where("completed_at > ?", 1.week.ago) }

  private

  def nillify_size
    self.size = nil if size.empty?
  end
end

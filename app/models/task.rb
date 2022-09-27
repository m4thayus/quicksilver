# frozen_string_literal: true

class Task < ApplicationRecord
  after_initialize :set_approved_to_be_false

  belongs_to :board, optional: true
  belongs_to :owner, class_name: "User", optional: true

  attr_accessor :approved

  validates :title, presence: true

  scope :active, -> { where(completed_at: nil) }
  scope :recently_completed, -> { where("completed_at > ?", 1.week.ago) }

  # def initialize(approved = false)
  #   @approved = approved
  # end

  # FIXME: This is bizarre. I hsould be able to put this in hte initializer
  def set_approved_to_be_false
    @approved = false
  end
end

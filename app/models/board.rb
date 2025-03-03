# frozen_string_literal: true

class Board < ApplicationRecord
  has_many :tasks, dependent: :nullify

  before_validation :parameterize_name

  validates :name, presence: true, uniqueness: true

  WISHLIST_SLUG = "wishlist"
  SUGGESTIONS_SLUG = "suggestions"
  BIZDEV_SLUG = "bizdev"

  def self.wishlist
    Board.find_by(name: WISHLIST_SLUG)
  end

  def self.suggestions
    Board.find_by(name: SUGGESTIONS_SLUG)
  end

  def self.bizdev
    Board.find_by(name: BIZDEV_SLUG)
  end

  def to_param
    name
  end

  private

  def parameterize_name
    self.name = name.parameterize if name.present?
  end
end

# frozen_string_literal: true

class Board < ApplicationRecord
  has_many :tasks, dependent: :nullify

  before_validation :parameterize_name

  validates :name, presence: true, uniqueness: true

  WISHLIST_SLUG = "wishlist"

  def self.wishlist
    Board.find_by(name: WISHLIST_SLUG)
  end

  def to_param
    name
  end

  private

  def parameterize_name
    self.name = name.parameterize if name.present?
  end
end

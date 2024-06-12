# frozen_string_literal: true

class User < ApplicationRecord
  has_many :tasks, dependent: :nullify

  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  ADMINISTRATORS = %w[scottb mattw].map { |u| "#{u}@mercuryanalytics.com" }.freeze
  ENGINEERS = %w[peterv deepthie elizabethk jamesa zoef biancac amitp].map { |u| "#{u}@mercuryanalytics.com" }.freeze
  MEMBERS = %w[ronh jail].map { |u| "#{u}@mercuryanalytics.com" }.freeze
  GUESTS = %w[andrewg praneetp prasadd aishwaryap jordank anastasiar jillianh brandonk shardulm].map { |u| "#{u}@mercuryanalytics.com" }.freeze

  def admin?
    ADMINISTRATORS.include?(email)
  end

  def engineer?
    ENGINEERS.include?(email) || admin?
  end

  def member?
    MEMBERS.include?(email) || engineer?
  end

  def guest?
    GUESTS.include?(email)
  end
end

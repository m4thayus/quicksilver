# frozen_string_literal: true

class User < ApplicationRecord
  has_many :tasks, dependent: :nullify

  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  ADMINISTRATORS = %w[scottb mattw].map { |u| "#{u}@mercuryanalytics.com" }.freeze
  ENGINEERS = %w[peterv elizabethk jamesa zoef biancac amitp].map { |u| "#{u}@mercuryanalytics.com" }.freeze
  MEMBERS = %w[ronh].map { |u| "#{u}@mercuryanalytics.com" }.freeze
  BUISNESS_DEVELOPERS = %w[jordank leighk].map { |u| "#{u}@mercuryanalytics.com" }.freeze
  GUESTS = %w[andrewg praneetp prasadd aishwaryap anastasiar jillianh brandonk shardulm].map { |u| "#{u}@mercuryanalytics.com" }.freeze

  def in_group?(group_slug)
    case group_slug
    when :admin
      ADMINISTRATORS.include?(email)
    when :engineer
      ENGINEERS.include?(email)
    when :member
      MEMBERS.include?(email)
    when :bizdev
      BUISNESS_DEVELOPERS.include?(email)
    when :guest
      GUESTS.include?(email)
    else
      false
    end
  end

  # TODO: Remove these two methods after board relationship redesign
  def admin?
    in_group?(:admin)
  end

  def engineer?
    in_group?(:engineer)
  end
end

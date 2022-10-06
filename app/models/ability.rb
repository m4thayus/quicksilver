# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user) # rubocop:disable Metrics/AbcSize
    return if user.blank?

    can :manage, user

    if user.member?
      can :read, Board
      can :read, User
      can :read, Task
      can :update, Task, :description
      can :manage, Task, board: Board.wishlist
      cannot :update, Task, %i[started_at expected_at completed_at board_id]
      cannot :create, Task, %i[started_at expected_at completed_at board_id]
    end

    if user.engineer?
      can :read, :all
      can :manage, Task
      can :manage, Board
    end

    can :manage, :all if user.admin?
  end
end

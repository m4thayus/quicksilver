# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return if user.blank?

    can :manage, user

    if user.guest?
      can :read, Board
      can :read, User
      can :read, Task
      can :manage, Task, board: Board.suggestions
      cannot :update, Task, %i[board_id started_at expected_at completed_at points point_estimate approved]
      cannot :create, Task, %i[board_id started_at expected_at completed_at points point_estimate approved]
    end

    if user.member?
      can :read, Board
      can :read, User
      can :read, Task
      can :update, Task, :description
      can :manage, Task, board: Board.wishlist
      cannot :update, Task, %i[board_id started_at expected_at completed_at points point_estimate]
      cannot :create, Task, %i[board_id started_at expected_at completed_at points point_estimate]
      can :manage, Task, board: Board.suggestions
    end

    if user.engineer?
      can :read, :all
      can :manage, Task
      can :manage, Board
    end

    can :manage, :all if user.admin?
  end
end

# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user) # rubocop:disable Metrics/MethodLength
    return if user.blank?

    can :search, Task
    can :manage, user

    if user.in_group?(:guest)
      can :read, Board
      can :read, User
      can :read, Task

      can :manage, Task, board: Board.suggestions

      cannot :update, Task, %i[board_id started_at expected_at completed_at points point_estimate approved]
      cannot :create, Task, %i[board_id started_at expected_at completed_at points point_estimate approved]
    end

    if user.in_group?(:bizdev)
      can :read, Board
      can :read, User
      can :read, Task

      can :manage, Task, board: Board.bizdev

      cannot :update, Task, %i[board_id started_at expected_at completed_at points point_estimate approved]
      cannot :create, Task, %i[board_id started_at expected_at completed_at points point_estimate approved]
    end

    if user.in_group?(:member)
      can :read, Board
      can :read, User
      can :read, Task

      can :update, Task, %i[description priority]
      can :manage, Task, board: Board.wishlist

      cannot :update, Task, %i[board_id started_at expected_at completed_at points point_estimate]
      cannot :create, Task, %i[board_id started_at expected_at completed_at points point_estimate]

      can :manage, Task, board: Board.suggestions
    end

    if user.in_group?(:engineer)
      can :read, :all
      can :manage, Task
      can :manage, Board
    end

    can :manage, :all if user.in_group?(:admin)
  end
end

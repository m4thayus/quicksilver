# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.blank?

    can :manage, user

    if user.member?
      can :read, Board
      can :read, User
      can :read, Task
      can %i[create update destroy], Task, board: Board.wishlist
    end

    if user.engineer?
      can :read, :all
      can :manage, Task
      can :manage, Board
    end

    can :manage, :all if user.admin?
  end
end

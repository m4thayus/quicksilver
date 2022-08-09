# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.blank?

    can :manage, user

    can :read, Task if user.member?
    can :read, User if user.member?

    can :read, :all if user.engineer?
    can :manage, Task if user.engineer?

    can :manage, :all if user.admin?
  end
end

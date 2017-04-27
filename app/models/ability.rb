class Ability
  include CanCan::Ability

  def initialize(user)
    if user.is_admin?
        can :manage, :all
    elsif user.is_approved?
        can :manage, [Nation, Import]
    else
        cannot :manage, :all
    end
  end
end
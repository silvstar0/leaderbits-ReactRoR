# frozen_string_literal: true

class TeamPolicy < ApplicationPolicy
  #TODO is this policy action still used somewhere?
  # def index?
  #   return true if user.team_member_in_any_team?
  #   return true if user.team_leader_in_any_team?
  #   return true if user.system_admin?
  #   return true if user.leaderbits_employee_with_access_to_any_organization?
  #
  #   return true if user.c_level?
  #
  #   false
  # end

  def show?
    return true if user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?

    record.organization == user.organization
  end

  def create?
    user.c_level?
  end

  def create_team_member?
    return false if record.users_who_can_be_added.blank?

    (user.c_level? && record.organization == user.organization) || user.leader_in_teams.include?(record)
  end

  #NOTE: this is just name updating
  def update?
    if user.c_level?
      return true if user.organization == record.organization
    end

    if user.team_leader_in_any_team?
      return true if user.leader_in_teams.include?(record)
    end

    false
  end
end

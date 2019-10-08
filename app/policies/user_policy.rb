# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def manage_preemptive_leaderbits_for?
    # pre-condition because any user can see himself
    return false if user == record

    show?
  end

  def show?
    return true if user == record

    return true if user.system_admin?

    return true if user.leaderbits_employee_with_access_to_any_organization?
    #any_organization check is fast
    #if user.leaderbits_employee_with_access_to_any_organization?
    #  return true if user.leaderbits_employee_with_access_to_organizations.include?(record.organization)
    #end

    return true if user.c_level? && user.organization == record.organization

    share_same_teams = (TeamMember.where(user: user).pluck(:team_id) & TeamMember.where(user: record).pluck(:team_id)).present?
    return true if share_same_teams

    OrganizationalMentorship.where(mentor_user_id: user.id, mentee_user_id: record.id).exists? || OrganizationalMentorship.where(mentee_user_id: user.id, mentor_user_id: record.id).exists?
  end

  def update?
    # return false if user.organization_id != record.organization_id
    # return true if user.c_level?
    # (user.leader_in_teams & record.member_in_teams).present?
    user.id == record.id
  end

  # NOTE: it is soft-delete instead
  def destroy?
    #NOTE: restore if/when you need to get it back, not used anywhere at the moment
    #!record.discarded? && update? && record != user
    false
  end

  def strength_levels?
    return true if user == record

    user.leaderbits_employee_with_access_to_any_organization? || user.system_admin?
  end

  def community?
    #TODO-low check user level?
    user.present?
  end

  def analytics?
    #TODO-low check user level?
    user.present?
  end
end

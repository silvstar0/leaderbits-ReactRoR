# frozen_string_literal: true

class LeaderbitPolicy < ApplicationPolicy
  def show?
    return true if user.system_admin?
    return true if user.leaderbits_employee_with_access_to_any_organization?
    return true if user.c_level?
    return true if user.team_leader_in_any_team?

    user.received_uniq_leaderbit_ids.include?(record.id)
  end

  def start?
    return false unless show?

    user.leaderbit_logs.where(leaderbit: record).blank?
  end
end

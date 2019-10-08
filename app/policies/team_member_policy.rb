# frozen_string_literal: true

class TeamMemberPolicy < ApplicationPolicy
  def update?
    return true if user.c_level? && user.organization == record.team.organization

    user.leader_in_teams.include?(record.team)
  end
end

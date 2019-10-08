# frozen_string_literal: true

class EntryGroupPolicy < ApplicationPolicy
  def mark_as_read?
    #!UserSeenEntryGroup.where(user: user, entry_group: record).exists?
    show? && !user.read?(entry_group: record)
  end

  #NOTE: we're consciously ignoring employee role because those users shouldn't see those entries in the first place
  #      because it is filtered on controller/fetching level
  def show?
    #TODO-low cache it?
    return true if user == record.user
    return true if user.system_admin?
    return true if user.leaderbits_employee_with_access_to_any_organization? #seems good enough for now

    return true if OrganizationalMentorship
                     .where('(mentor_user_id = ? AND mentee_user_id = ?) OR (mentor_user_id = ? AND mentee_user_id = ?)', user.id, record.user_id, record.user_id, user.id)
                     .exists?

    if user.c_level?
      return user.organization_id == record.user.organization_id
    end

    share_same_teams = (TeamMember.where(user: user).pluck(:team_id) & TeamMember.where(user: record.user).pluck(:team_id)).present?
    return true if share_same_teams

    record.user.progress_report_recipients.where(user: user).exists?
  end
end

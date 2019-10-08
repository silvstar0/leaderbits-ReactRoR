# frozen_string_literal: true

class EntryPolicy < ApplicationPolicy
  #TODO-low rename policy action, it belongs to EntryGroup instead
  def index?
    #TODO-High is there any reason left for prohibiting this action from being accessed?

    #return true if user.c_level?
    #return true if user.system_admin?
    #return true if user.leaderbits_employee_with_access_to_any_organization?
    #return true if user.team_leader_in_any_team?
    #return true if user.mentor_for_any_user?
    #return true if EntryReply.where('entry_id IN(SELECT id FROM entries WHERE user_id = ?)', user.id).exists?
    #user.entries.count.positive?

    true
  end

  def update?
    user.id == record.user.id
  end

  #NOTE: we're consciously ignoring employee role because those users shouldn't see those entries in the first place
  def reply_to?
    return true if user == record.user
    return true if user.system_admin?
    return true if user.leaderbits_employee_with_access_to_any_organization? #secure enough for now
    return true if user.mentor_for_any_user?
    if user.c_level?
      return user.organization_id == record.user.organization_id
    end

    return true if (user.leader_in_teams & record.user.member_in_teams).present?
    return true if (user.member_in_teams & record.user.member_in_teams).present?

    record.user.progress_report_recipients.where(user: user).exists?
  end

  def toggle_like?
    #we purposely allow everyone to like everything because everything is filtered in LikedMessageGenerator anyways
    true
    #return true if user == record.user
    #return true if user.system_admin?
    #return true if user.leaderbits_employee_with_access_to_any_organization? #secure enough for now

    #UserSeenEntryGroup.where(user: user, entry_group: record.entry_group).exists?
    #user.seen?(entry_group: record.entry_group)
  end

  def destroy?
    record.user == user
  end
end

# frozen_string_literal: true

class OrganizationalMentorshipPolicy < ApplicationPolicy
  def accept?
    #NOTE: we've extacted #accepted_at check to higher level(controller)
    record.mentee_user == user
  end
end

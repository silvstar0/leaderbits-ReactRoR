# frozen_string_literal: true

class EntryReplyPolicy < ApplicationPolicy
  def update?
    user.id == record.user.id
  end

  def destroy?
    update?
  end

  def joels_responses?
    user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
  end
end

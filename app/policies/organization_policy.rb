# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  def preview_organization_engagement_as_admin?
    user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
  end

  def billing?
    return false unless user.organization == record

    #we check if this is one-person organization because
    # NOT all users of such organizations were granted C-Level role
    user.system_admin? || user.c_level? || record.individual?
  end
end

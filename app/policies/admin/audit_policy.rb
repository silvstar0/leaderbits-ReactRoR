# frozen_string_literal: true

module Admin
  class AuditPolicy < ApplicationPolicy
    def index?
      user.system_admin? # || user.leaderbits_employee_with_access_to_any_organization?
    end
  end
end

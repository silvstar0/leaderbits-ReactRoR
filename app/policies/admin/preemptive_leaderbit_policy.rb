# frozen_string_literal: true

module Admin
  class PreemptiveLeaderbitPolicy < ApplicationPolicy
    def create?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def destroy_by_leaderbit_id?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def sort?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end
  end
end

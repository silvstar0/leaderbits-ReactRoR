# frozen_string_literal: true

module Admin
  class LeaderbitPolicy < ApplicationPolicy
    def index?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def show?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def create?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def update?
      # There could be potential issue with updating inactive leaderbit and making it active again
      # in terms of sending queue order. How critical is it? Anything we can do to prevent it?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end
  end
end

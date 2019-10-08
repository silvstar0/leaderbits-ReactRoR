# frozen_string_literal: true

module Admin
  class SchedulePolicy < ApplicationPolicy
    def index?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def show?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def create?
      user.system_admin?
    end

    def update?
      user.system_admin?
    end

    def clone?
      user.system_admin?
    end

    def sort?
      #NOTE: you may later need to allow employee to adjust it
      # but condition could be rather complicated. Smth like "check whether this schedule is only for people I can see & manage(in my assigned organizations)"
      user.system_admin?
    end

    def add_leaderbit?
      user.system_admin?
    end

    def remove_leaderbit?
      user.system_admin?
    end

    def destroy?
      user.system_admin? && record.users_count.zero?
    end
  end
end

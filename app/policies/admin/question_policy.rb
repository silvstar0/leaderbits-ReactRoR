# frozen_string_literal: true

module Admin
  class QuestionPolicy < ApplicationPolicy
    def show?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def sort?
      #user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
      user.system_admin?
    end

    def create?
      #user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
      user.system_admin?
    end

    def update?
      # user.leaderbits_employee_with_access_to_any_organization?
      #   #TODO move this to the actual form and allow only tags updating?
      #   # unless record.answers.exists?
      # end

      user.system_admin?
    end

    def destroy?
      user.system_admin?
    end
  end
end

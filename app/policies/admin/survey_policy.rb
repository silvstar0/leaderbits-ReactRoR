# frozen_string_literal: true

module Admin
  class SurveyPolicy < ApplicationPolicy
    def index?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def show?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def update?
      user.system_admin?
    end
  end
end

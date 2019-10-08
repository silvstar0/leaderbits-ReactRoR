# frozen_string_literal: true

module Admin
  class UserPolicy < ApplicationPolicy
    #override parent initializer, explicitly prohibit anonymous use(do not raise exception)
    def initialize(user, record)
      #raise Pundit::NotAuthorizedError, "must be logged in" unless user

      @user = user
      @record = record
    end

    def index?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def show?
      return true if user.system_admin?

      return true if user.leaderbits_employee_with_access_to_any_organization?

      # if user.leaderbits_employee_with_access_to_any_organization?
      #   user.leaderbits_employee_with_access_to_organizations.include? record.organization
      # else
      #   false
      # end
      false
    end

    def create?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    # admin/users
    def update?
      # prevent employee role from updating Joel's account. Important because that name is displayed everywhere in entry responses
      if record.email == Rails.configuration.joel_email || record.id == 1
        return user.system_admin?
      end

      return true if user.system_admin?

      if user.leaderbits_employee_with_access_to_any_organization?
        return true if user.leaderbits_employee_with_access_to_organizations.include?(record.organization)
      end

      false
    end

    def toggle_discard?
      return false if record.email == Rails.configuration.joel_email || record.id == 1

      return false if user.id == record.id
      return true if user.system_admin?

      if user.leaderbits_employee_with_access_to_any_organization?
        return true if user.leaderbits_employee_with_access_to_organizations.include?(record.organization)
      end

      false
    end

    # NOTE: this is actual destroying, not self-deleting
    def destroy?
      return false if record.email == Rails.configuration.joel_email || record.id == 1
      return false if record.leaderbits_employee_with_access_to_any_organization?

      return false if user.id == record.id
      return true if user.system_admin?

      false
    end

    #NOTE: this condition is used in BOTH:
    # view helper condition
    # SwitchUser configuration(controller_guard block)
    def switch_user_as?
      return false if user.nil?
      return false if user.id == record.id

      # prevent employee from escalating his role
      if record.system_admin? && !user.system_admin?
        return false
      end

      if user.leaderbits_employee_with_access_to_any_organization?
        return true if user.leaderbits_employee_with_access_to_organizations.include?(record.organization)
      end

      user.system_admin?
    end

    def regenerate_email_authentication_token?
      user.system_admin?
    end

    def send_lifetime_progress_report?
      return false unless record.lifetime_completed_leaderbit_logs.exists?

      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def send_leaderbit_manually?
      return false if record.discarded?

      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def add_leaderbit_to_preemptive_queue?
      #TODO test it for employee
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end
  end
end

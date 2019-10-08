# frozen_string_literal: true

module Admin
  class OrganizationPolicy < ApplicationPolicy
    def index?
      user.system_admin? || user.leaderbits_employee_with_access_to_any_organization?
    end

    def show?
      return true if user.system_admin?

      if user.leaderbits_employee_with_access_to_any_organization?
        return true if user.leaderbits_employee_with_access_to_organizations.include?(record)

        #can see everything as of Feb 2019 that is Allison
        return true if user.leaderbits_employee_with_access_to_organizations.collect(&:name).include?(official_leaderbits_org_names)
      end
      false
    end

    def create?
      return true if user.system_admin?

      (user.leaderbits_employee_with_access_to_organizations.collect(&:name) & official_leaderbits_org_names).present?
    end

    def update?
      return true if user.system_admin?

      if user.leaderbits_employee_with_access_to_any_organization?
        return true if user.leaderbits_employee_with_access_to_organizations.include?(record)
      end
      false
    end

    # NOTE: it is soft-delete instead
    def destroy?
      #prevent umbrella account from being deleted/marked as deleted
      return false if record.id == 1 || record.name == 'LeaderBits'
      return true if user.system_admin?

      if user.leaderbits_employee_with_access_to_any_organization?
        return true if user.leaderbits_employee_with_access_to_organizations.include?(record)
      end
      false
    end

    def send_lifetime_progress_report?
      #include employee?
      user.system_admin? && record.lifetime_completed_leaderbit_logs.exists?
    end
  end
end

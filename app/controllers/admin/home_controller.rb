# frozen_string_literal: true

module Admin
  class HomeController < BaseController
    add_breadcrumb 'Admin'

    def root
      add_breadcrumb 'Dashboard', request.path

      @users_for_welcome_video_stats = User
                                         .where(leaderbits_sending_enabled: true)
                                         .where('organizations.leaderbits_sending_enabled = ?', true)
                                         .where('schedule_id IS NOT NULL')
                                         .joins(:organization)
                                         .order(created_at: :desc)
    end

    def report
      add_breadcrumb 'Report', request.path

      @users = Admin::UserDecorator.decorate_collection User
                                                          .yield_self(&method(:role_clause))
                                                          .where.not(schedule_id: nil)
                                                          .order(:name)
                                                          .includes(:organization)
    end

    private

    def role_clause(relation)
      return relation if current_user.system_admin?

      organization_ids = current_user.leaderbits_employee_with_access_to_organizations.collect(&:id)

      relation
        .where(organization: organization_ids)
    end
  end
end

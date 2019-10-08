# frozen_string_literal: true

class InvestigationsController < ActionController::Base
  def show
    raise unless user_signed_in?
    raise if !current_user.system_admin? && !current_user.leaderbits_employee_with_access_to_any_organization?

    @organizations = Organization
                       .where(leaderbits_sending_enabled: true)
                       .where('users_count <> ? ', 1)
                       .order(created_at: :desc)

    respond_to do |format|
      format.html { render layout: 'devise' }
    end
  end
end

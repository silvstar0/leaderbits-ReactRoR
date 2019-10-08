# frozen_string_literal: true

module Admin
  class AuditsController < BaseController
    add_breadcrumb 'Admin'
    add_breadcrumb 'Audits', %i[admin audits]

    def index
      anything_really = Audited::Audit.all.sample
      authorize anything_really, policy_class: Admin::AuditPolicy

      #TODO abstract and DRY fitlered(noisy) auditable_type
      @audits = Audited::Audit.where.not(auditable_type: LeaderbitEmployeeMentorship.to_s)
                  .paginate(page: params[:page], per_page: 20)
                  .order(created_at: :desc)

      current_user.touch(:last_seen_audit_created_at)
    end
  end
end

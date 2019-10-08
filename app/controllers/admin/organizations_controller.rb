# frozen_string_literal: true

module Admin
  class OrganizationsController < BaseController
    include ActionView::Helpers::TextHelper # for pluralize

    add_breadcrumb 'Admin'
    add_breadcrumb 'Accounts', %i[admin organizations]

    before_action :set_organization, only: %i[show edit update destroy send_lifetime_progress_report]

    def index
      authorize [:admin, Organization]
      @organizations = Organization
                         .kept
                         .yield_self(&method(:fuzzy_search_clause))
                         .yield_self(&method(:visible_by_role_clause))
                         .order(order_by[:value])
                         .paginate(page: params[:page], per_page: 20)
    end

    def show
      authorize [:admin, @organization]
    end

    def new
      @organization = Organization.new
      @organization.leaderbits_sending_enabled = true

      @organization.active_since = Time.zone.now.beginning_of_day

      authorize [:admin, @organization]
    end

    def create
      @organization = Organization.new(account_params)

      authorize [:admin, @organization]

      if @organization.save
        unless current_user.system_admin?
          # solves issue when employee creates new Account and can't instantly access it
          LeaderbitsEmployee.create! user: current_user, organization: @organization
        end
        redirect_to [:admin, @organization], notice: 'Organization successfully created.'
      else
        render :new, alert: 'Account could not be created.'
      end
    end

    def edit
      authorize [:admin, @organization]

      add_breadcrumb @organization.name, admin_organization_path(@organization.to_param)
    end

    def update
      authorize [:admin, @organization]

      add_breadcrumb @organization.name, admin_organization_path(@organization.to_param)

      if @organization.update(account_params)
        redirect_to [:admin, @organization], notice: 'Account successfully updated.'
      else
        render :edit, alert: 'Account could not be updated.'
      end
    end

    def destroy
      authorize [:admin, @organization]

      if @organization.discard
        redirect_to %i[admin organizations], notice: 'Account successfully marked as destroyed.'
      else
        redirect_to [:admin, @organization], notice: 'Account could not be destroyed.'
      end
    end

    def send_lifetime_progress_report
      authorize [:admin, @organization]

      email = params.fetch(:recipient_email)

      AdminMailer
        .with(organization: @organization, recipient_email: email)
        .organization_lifetime_progress_dump
        .deliver_now

      recipient_user = User.where(email: email).first
      if recipient_user.present?
        OrganizationSentProgressDump.create! user: recipient_user,
                                             organization: @organization
      end

      redirect_to [:admin, @organization], notice: "Lifetime progress report has been sent(#{pluralize @organization.lifetime_completed_leaderbit_logs.count, 'record'}) to #{email}"
    end

    private

    def fuzzy_search_clause(relation)
      if params[:query].present?
        relation.fuzzy_search(name: params[:query])
      else
        relation
      end
    end

    def visible_by_role_clause(relation)
      if current_user.system_admin?
        relation
      elsif current_user.leaderbits_employee_with_access_to_any_organization?
        relation.where(id: current_user.leaderbits_employee_with_access_to_organizations.collect(&:id))
      else
        raise
      end
    end

    def set_organization
      @organization = Organization.find(params[:id])
    end

    def account_params
      params.require(:organization).permit(
        :active_since,
        :custom_default_schedule_id,
        :day_of_week_to_send,
        :hour_of_day_to_send,
        :first_leaderbit_introduction_message,
        :leaderbits_sending_enabled,
        :logo,
        :name,
        :stripe_customer_id
      )
    end
  end
end

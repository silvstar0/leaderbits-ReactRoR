# frozen_string_literal: true

class ProfileController < ApplicationController
  before_action :authenticate_user!

  before_action :fetch_team, only: %i[engagement]
  skip_before_action :verify_authenticity_token, only: %i[billing]

  def setting_password
    @organization = current_user.organization # needed in case of validation errors and "users/edit" template rendering"

    @user = current_user

    #TODO extract and document encrypted_password.present? check
    result = if @user.existing_password_exists?
               #handling it manually because https://github.com/plataformatec/devise/issues/2349

               if user_password_params.fetch(:password).blank?
                 @user.errors.add(:password, :blank)
                 false
               else
                 @user.update_with_password(user_password_params)
               end
             else
               @user.update(user_password_params).tap { |_user| @user.clean_up_passwords }
             end
    if result
      # Sign in the user by passing validation in case their password changed
      bypass_sign_in(@user)
      unobtrusive_flash.regular type: :notice, message: "Password successfully updated."

      redirect_to edit_user_path(@user)
    else
      render 'users/edit'
    end
  end

  #TODO-low we may(temporarily?) disable testing it on staging. Does anyone use it?
  def billing
    authorize current_user.organization
    if request.get?
      load_receipts
      if current_user.organization.stripe_customer.present?
        @default_card = current_user.organization.default_card

        if @default_card.present?
          @masked_card_number = "**** **** **** #{@default_card.last4}"
          @button_label = "Update Credit Card"
        else
          @button_label = "Add Credit Card"
        end
      else
        @button_label = "Add Credit Card"
      end
    else
      #{"stripeToken"=>"tok_1DMMCKBtjjIyBvbaLqcBqsD4", "stripeTokenType"=>"card", "stripeEmail"=>"user@gmail.com", "controller"=>"home", "action"=>"stripe"}
      if current_user.organization.stripe_customer_id.blank?
        #You do not have to assign a source to create a customer.
        # However, if you set the customer up on a subscription, they will require a source to be available, and the charges will be made to the customer's default_source.
        # If a customer has only one source, it is automatically the default_source.
        customer = Stripe::Customer.create(
          source: params.fetch(:stripeToken),
          email: params.fetch(:stripeEmail)
        )
        organization = current_user.organization
        organization.stripe_customer_id = customer.id
        organization.save!
      else
        #you can also add a new card to an existing customer, using a token:
        customer = Stripe::Customer.retrieve(current_user.organization.stripe_customer_id)
        stripe_card = customer.sources.create(source: params.fetch(:stripeToken))

        #Once you have a card assigned to the customer, you can make it the default_source, using this:
        customer.default_source = customer.sources.retrieve(stripe_card.id)
        customer.save
      end

      # so that you can't simulate same POST request multiple times(stripeToken must be unique)
      redirect_to profile_billing_path
    end
  end

  def engagement
    if params[Rails.configuration.preview_organization_engagement_as_admin].present?
      @preview_organization_as_admin = Organization.find(params[Rails.configuration.preview_organization_engagement_as_admin])

      #NOTE: this authorize check is very important - otherwise anyone can pick any organization and see all the entries
      authorize @preview_organization_as_admin, :preview_organization_engagement_as_admin?
    end

    if params[:layout].blank?
      #NOTE: in case arguments change, keep it in sync with
      # #as_engagement_user
      # #entries_link
      # #value_link
      # #emails_link
      # #all_link
      # #unread_link
      # form_tag profile_engagement_path
      redirect_to profile_engagement_path(layout: 'value',
                                          request_type: params[:request_type],
                                          uuid: params[:uuid],
                                          Rails.configuration.preview_organization_engagement_as_admin => params[Rails.configuration.preview_organization_engagement_as_admin])
      return
    end

    if entries_layout?
      if params[:status].blank?
        #NOTE: in case arguments change, keep it in sync with
        # #as_engagement_user
        # #entries_link
        # #value_link
        # #emails_link
        # #all_link
        # #unread_link
        # form_tag profile_engagement_path
        redirect_to profile_engagement_path(layout: 'entries',
                                            status: 'all',
                                            request_type: params[:request_type],
                                            uuid: params[:uuid],
                                            Rails.configuration.preview_organization_engagement_as_admin => params[Rails.configuration.preview_organization_engagement_as_admin])
        return
      end
    end

    @filtered_users = if @team.present?
                        @team.users
                      elsif @preview_organization_as_admin.present?
                        @preview_organization_as_admin
                          .users
                          .where('organization_id = ?', @preview_organization_as_admin.id)
                          .where.not(schedule_id: nil)
                      #NOTE: Fabiana requested "People I mentor"|"Mentors" not to be displayed in case of organization engagement report preview as an admin
                      elsif params[:request_type].to_s == EngagementHelper::PEOPLE_I_MENTOR.to_s
                        #TODO-High think about admin switching - waiting for answers from Fabiana
                        user_ids = OrganizationalMentorship.where(mentor_user: current_user).pluck(:mentee_user_id)
                        User.where(id: user_ids)
                      else
                        current_user.can_see_users_in_own_organization
                      end

    @all_users_in_selector = if @preview_organization_as_admin.present?
                               @preview_organization_as_admin
                                 .users
                                 .where('organization_id = ?', @preview_organization_as_admin.id)
                                 .where.not(schedule_id: nil)
                             else
                               current_user.can_see_users_in_own_organization
                             end

    # this is a workaround for individual organizations - otherwise "Group analytics" looks weird for a single person
    if params[:uuid].blank? && @filtered_users.count == 1 && params[:request_type].blank?
      #NOTE: in case arguments change, keep it in sync with
      # #as_engagement_user
      # #entries_link
      # #value_link
      # #emails_link
      # #all_link
      # #unread_link
      # form_tag profile_engagement_path
      redirect_to profile_engagement_path(layout: params[:layout],
                                          status: params[:status],
                                          request_type: params[:request_type],
                                          uuid: @filtered_users.first.uuid,
                                          Rails.configuration.preview_organization_engagement_as_admin => params[Rails.configuration.preview_organization_engagement_as_admin])
      return
    end

    #Fixes #166887594 If a C level
    #01) By default it loads the first team that C-level is part of. If C-level is not part of a team, by default it loads "all users".
    #if params[Rails.configuration.preview_organization_engagement_as_admin].blank? && @team.blank? && current_user.c_level? && params[:request_type].blank?
    if params[Rails.configuration.preview_organization_engagement_as_admin].blank? && @team.blank? && params[:request_type].blank?
      member_in_team_ids = TeamMember.where(user: current_user).pluck(:team_id)
      if member_in_team_ids.present?

        redirect_to profile_engagement_path(layout: params[:layout],
                                            status: params[:status],
                                            request_type: "team.#{member_in_team_ids.first}",
                                            uuid: params[:uuid],
                                            Rails.configuration.preview_organization_engagement_as_admin => params[Rails.configuration.preview_organization_engagement_as_admin])
        return
      end
    end

    @users_i_mentor = if @preview_organization_as_admin.present?
                        #NOTE: Fabiana requested "People I mentor"|"Mentors" not to be displayed in case of organization engagement report preview as an admin
                        []
                      else
                        OrganizationalMentorship
                          .where(mentor_user: current_user)
                          .includes(:mentee_user)
                          .collect(&:mentee_user)
                          .sort(&by_momentum)
                      end

    #TODO rename to include right selector words?
    @teams_with_users = if @preview_organization_as_admin.present?
                          @preview_organization_as_admin
                            .teams
                            .collect { |team| [team, team.users.sort(&by_momentum)] }
                        else
                          current_user
                            .with_access_to_teams_with_any_role
                            .collect { |team| [team, team.users.sort(&by_momentum)] }

                        end

    if value_layout?
      if individual_engagement_request?
        @user = User.find_by_uuid(params[:uuid])
        @total_actions_taken_count = @user.leaderbit_logs.completed.count

        authorize @user, :show?
      else
        #ct-chart-top-people
        #ct-chart-by-month
        @total_actions_taken_count = LeaderbitLog
                                       .completed
                                       .where(user_id: @filtered_users.collect(&:id))
                                       .count

        @top_users = @filtered_users.sort(&by_momentum).take(5)
        @top_people_leaderbit_logs = LeaderbitLog
                                       .completed
                                       .where(user_id: @top_users.collect(&:id))
                                       .includes(:leaderbit, :user)
      end

      #BOTH: individual ang group
      @all_leaderbit_logs = LeaderbitLog
                              .completed
                              .yield_self(&method(:user_clause))
                              .includes(:user, leaderbit: [video_cover_attachment: :blob])

    elsif entries_layout?
      base_scope = if params[:uuid].present? # focused request
                     #TODO check if this this safe enough.
                     EntryGroup
                       .exclude_discarded_users
                       .yield_self(&method(:focused_by_user_clause_if_set))
                       .includes(:leaderbit, entries: [:user, replies: { user: :organization }], user: %i[organization schedule])
                       .order(newest_first_order)
                       .paginate(page: params[:page], per_page: 7)
                   elsif @preview_organization_as_admin.present?
                     EntryGroup
                       .exclude_discarded_users
                       .where("entry_groups.user_id IN (SELECT id FROM users WHERE organization_id = ?)", @preview_organization_as_admin.id)
                       .includes(:leaderbit, entries: [:user, replies: { user: :organization }], user: %i[organization schedule])
                       .order(newest_first_order)
                       .paginate(page: params[:page], per_page: 7)
                   else
                     EntryGroup
                       .exclude_discarded_users
                       .yield_self(&method(:if_no_special_parameter_or_filtering_is_set_clause))
                       .includes(:leaderbit, entries: [:user, replies: { user: :organization }], user: %i[organization schedule])
                       .order(newest_first_order)
                       .paginate(page: params[:page], per_page: 7)
                   end

      if @team.present?
        team_user_ids = @team.users.collect(&:id)
        team_user_ids = [-1] if team_user_ids.blank?

        base_scope = base_scope.where('users.id IN(?)', team_user_ids)
      end

      if params[:status] == 'all'
        # F I X M E security
        @entry_groups = base_scope
      elsif params[:status] == 'unread'
        @entry_groups = base_scope.unseen_by_user(current_user)
      else
        raise("unknown status type: #{params.inspect}")
      end
    elsif emails_layout?
      @user_sent_emails = UserSentEmail
                            .where(user: @filtered_users)
                            .includes(:user, :resource)
                            .yield_self(&method(:focused_by_user_clause_if_set))
                            .sort_by(&:created_at)
                            .reverse
                            .select(&:visible_in_engagement?)
                            .paginate(page: params[:page], per_page: 70)
    else
      raise("unknown layout type #{params.inspect}")
    end
  end

  def mentorship
    if params[:new].present?
      @organizational_mentorship = OrganizationalMentorship.new
    elsif params[:edit].present?
      @organizational_mentorship = OrganizationalMentorship.where(mentor_user_id: current_user.id, id: params[:edit]).first!
    end
  end

  def team_survey_360
    load_user_and_team_survey_results

    if params[:new].present?
      @anonymous_survey_participant = AnonymousSurveyParticipant.new
    elsif params[:edit].present?
      @anonymous_survey_participant = current_user.anonymous_survey_participants.find(params[:edit])
    end
  end

  def accountability
    if params[:new].present?
      @progress_report_recipient = ProgressReportRecipient.new
    elsif params[:edit].present?
      @progress_report_recipient = current_user.progress_report_recipients.find(params[:edit])
    end
  end

  def entries_layout?
    params[:layout] == 'entries'
  end
  helper_method :entries_layout?

  def value_layout?
    params[:layout] == 'value'
  end
  helper_method :value_layout?

  def emails_layout?
    params[:layout] == 'emails'
  end
  helper_method :emails_layout?

  def status_all?
    params[:status] == 'all'
  end
  helper_method :status_all?

  def status_unread?
    params[:status] == 'unread'
  end
  helper_method :status_unread?

  private

  def fetch_team
    if params[:request_type].to_s.start_with?("team.")
      team_id = params[:request_type].scan(/\d+/).first
      @team = Team.find(team_id)
      authorize @team, :show?
    end
  end

  def load_receipts
    # so that you can easily adjust and test the styling
    if Rails.env.development?
      @charges = [
        OpenStruct.new(receipt_number: '3707-0419', paid: [true, false].sample, currency: 'usd', status: 'succeeded', amount: 14_400, amount_refunded: 14_400, refunded: true, receipt_url: 'https://google.com', created: 51.minutes.ago),
        OpenStruct.new(receipt_number: '3707-0429', paid: [true, false].sample, currency: 'cad', status: 'succeeded', amount: 24_400, amount_refunded: 0, refunded: false, receipt_url: 'https://google.com', created: 1151.minutes.ago),
        OpenStruct.new(receipt_number: '3707-0479', paid: [true, false].sample, currency: 'eur', status: 'succeeded', amount: 34_400, amount_refunded: 0, refunded: false, receipt_url: 'https://google.com', created: 2251.minutes.ago)
      ]
      return
    end

    return if current_user.organization.stripe_customer_id.blank?

    @charges = Stripe::Charge.list(customer: current_user.organization.stripe_customer_id)
  end

  def user_clause(relation)
    if @user.present?
      relation.where(user_id: @user.id)
    else
      relation.where(user_id: @filtered_users.collect(&:id))
    end
  end

  #TODO looks very duplicated to specific_user_clause_if_set
  def focused_by_user_clause_if_set(relation)
    if uuid = params[:uuid]
      return relation if uuid.blank?

      user = User.find_by_uuid(uuid)
      relation.where(user_id: user.id)
    else
      relation
    end
  end

  def if_read_clause(relation)
    if params[:unread].present?
      relation.unseen_by_user(current_user)
    else
      relation
    end
  end

  def user_password_params
    params.require(:user).permit(:current_password,
                                 :password,
                                 :password_confirmation)
  end
end

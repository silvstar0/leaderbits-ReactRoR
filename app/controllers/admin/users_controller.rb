# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    include ActionView::Helpers::TextHelper # for pluralize

    add_breadcrumb 'Admin'
    add_breadcrumb 'Users', %i[admin users]
    skip_before_action :verify_authenticity_token, only: [:sort_preemptive_leaderbits]

    before_action :set_user, only: %i[edit update toggle_discard destroy send_lifetime_progress_report password_reset]

    def index
      authorize [:admin, User]

      #restore .kept filtering in case you want to hide discarded users
      @base_relation_without_type_filters = User
                                              .includes(:organization)
                                              .yield_self(&method(:visible_by_role_clause))
                                              .yield_self(&method(:search_clause))
                                              .yield_self(&method(:specific_ids_if_specified))
                                              .order(order_by[:value])

      collection_to_decorate = @base_relation_without_type_filters
                                 .yield_self(&method(:active_clause))
                                 .yield_self(&method(:inactive_clause))
                                 .yield_self(&method(:mentors_clause))
                                 .yield_self(&method(:mentees_clause))
                                 .paginate(page: params[:page], per_page: 30)

      @users = Admin::UserDecorator.decorate_collection collection_to_decorate
    end

    def show
      user = User.find_by_uuid!(params[:id])

      authorize [:admin, user]

      @user = Admin::UserDecorator.decorate user

      @vacation_modes = user.vacation_modes.order(starts_at: :desc)

      #TODO as soon as we have ongoing surveying this no longer works:
      @anonymous_survey_completed_times = AnonymousSurveyParticipant
                                            .where(added_by_user_id: @user.id)
                                            .where('id IN(SELECT anonymous_survey_participant_id FROM answers WHERE user_id IS NULL)')
                                            .count

      if @user.schedule_id.present?
        @all_active_leaderbits_from_schedule = @user.all_active_leaderbits_from_schedule

        #TODO-low need better api
        @all_active_personalized_leaderbits_from_schedule = PersonalizedLeaderbitsQueue.new(@user).call

        @all_active_preemptive_leaderbits = @user.all_preemptive_active_leaderbits

        @all_user_sent_emails = @user.user_sent_emails

        # TODO need better naming
        @answers = @user.answers
      end
    end

    def new
      authorize [:admin, User]

      @user = User.new
      @user.leaderbits_sending_enabled = true
      @user.organization_id = params[:organization_id]

      organization = @user.organization_id.present? ? Organization.find(@user.organization_id) : nil
      latest_user_in_organization = organization.present? ? organization.users.where('users.schedule_id IS NOT NULL').order(created_at: :asc).last : nil

      if organization.present? && latest_user_in_organization.present?
        @user.goes_through_leader_welcome_video_onboarding_step = !!latest_user_in_organization.goes_through_leader_welcome_video_onboarding_step
        @user.goes_through_leader_strength_finder_onboarding_step = !!latest_user_in_organization.goes_through_leader_strength_finder_onboarding_step
        @user.goes_through_team_survey_360_onboarding_step = !!latest_user_in_organization.goes_through_team_survey_360_onboarding_step

        @user.hour_of_day_to_send = latest_user_in_organization.hour_of_day_to_send
        @user.day_of_week_to_send = latest_user_in_organization.day_of_week_to_send

        @user.can_create_a_mentee = !!latest_user_in_organization.can_create_a_mentee

        @user.personalized_leaderbits_algorithm_instead_of_regular_schedule = !!latest_user_in_organization.personalized_leaderbits_algorithm_instead_of_regular_schedule

        @user.schedule_id = latest_user_in_organization.schedule_id
        @user.leaderbits_sending_enabled = !!latest_user_in_organization.leaderbits_sending_enabled

        @user.time_zone = latest_user_in_organization.time_zone
      else
        @user.goes_through_leader_welcome_video_onboarding_step = true
        @user.goes_through_leader_strength_finder_onboarding_step = true
        @user.goes_through_team_survey_360_onboarding_step = true

        @user.hour_of_day_to_send = organization.try(:hour_of_day_to_send)
        @user.day_of_week_to_send = organization.try(:day_of_week_to_send)

        @user.schedule_id = organization.try(:custom_default_schedule_id) || Schedule.find_by_name(Schedule::GLOBAL_NAME).id

        @user.time_zone = User.order(created_at: :asc).last.time_zone
      end

      #Fabiana: "Option: "Goes through organizational mentorship onboarding step is" - The most common option for this one is Disabled. So, we want to let as it was and not bring it enabled when we are adding a new user. It will be selected manually if needed."
      @user.goes_through_organizational_mentorship_onboarding_step = false
    end

    def create
      authorize [:admin, User]
      user_params = params.permit!.to_h
      user_params[:user][:created_by_user_id] = current_user.id
      Admin::CreateUser.new.call(user_params) do |result|
        result.success do |user|
          redirect_to [:admin, user], notice: 'User successfully created.'
        end
        result.failure :validate do |user|
          @user = user

          render :new, alert: 'User could not be created.'
        end
      end
    end

    def edit
      authorize [:admin, @user]
      add_breadcrumb @user.name, admin_user_path(@user.uuid)

      @possible_new_mentor_users = User
                                     .where(organization: @user.organization)
                                     .where('id NOT IN(SELECT mentor_user_id FROM organizational_mentorships WHERE mentee_user_id = ?)', @user.id)
                                     .where.not(id: @user.id)
    end

    def update
      authorize [:admin, @user]

      add_breadcrumb @user.name, admin_user_path(@user.uuid)

      Admin::UpdateUser.new.call(params.permit!.to_h) do |result|
        result.success do |user|
          redirect_to [:admin, user], notice: 'User successfully updated.'
        end
        result.failure :validate do |user|
          @user = user

          render :edit, alert: 'User could not be updated.'
        end
      end
    end

    def toggle_discard
      authorize [:admin, @user]

      if @user.discarded?
        @user.undiscard

        #TODO-low notice may also include note about "dont forget to assign schedule(if it is missing)"

        redirect_to [:admin, @user], notice: 'User successfully unlocked.'
        return
      end

      @user.discard
      redirect_to [:admin, @user], notice: 'User successfully marked as destroyed(locked).'
    end

    def destroy
      authorize [:admin, @user]

      if @user.destroy
        redirect_to %i[admin users], notice: 'User successfully destroyed.'
      else
        redirect_to [:admin, @user], notice: 'User could not be destroyed.'
      end
    end

    def trigger_next_leaderbit_instant_sending
      user = User.find_by_uuid!(params[:id])

      leaderbit = user.next_leaderbit_to_send
      if leaderbit.present?
        LeaderbitMailer
          .with(
            user: user,
            leaderbit: leaderbit
          )
          .new_leaderbit
          .deliver_now

        # NOTE: it is important to create UserSentScheduledLeaderbit *after* mailer sending
        # otherwise user will receive wrong kind of notification(New Leaderbit Challenge instead of Welcome to LeaderBits.io)
        UserSentScheduledNewLeaderbit.create! user: user,
                                              resource: leaderbit,
                                              created_at: 1.second.ago

        SaveHistoricMomentumValues.call_for_user user

        redirect_to [:admin, user], notice: "#{leaderbit.name} has just been sent to #{user.name}"
      else
        raise("can not find leaderbit to send to #{user.inspect}")
      end
    end

    def password_reset
      # what it(devise) does internally:
      # User Update (2.0ms)  UPDATE "users" SET "reset_password_token" = $1t" = $2, "updated_at" = $3 WHERE "users"."id" = $4  [["reset_passwordefa53f77ec112f9fe21dda6b3d88b04586b2ad1db91f7dce1b"], ["reset_passwor16:18:50.690022"], ["updated_at", "2018-11-21 16:18:50.690782"], ["id
      # => "eo8biog6HGQnARGyPD7s"

      @token = @user.send(:set_reset_password_token)
    end

    def send_lifetime_progress_report
      authorize [:admin, @user]

      AdminMailer
        .with(user: @user)
        .user_lifetime_progress_dump
        .deliver_now

      @user.user_sent_progress_dumps.create!

      redirect_to [:admin, @user], notice: "Lifetime progress report has been sent(#{pluralize @user.lifetime_completed_leaderbit_logs.count, 'record'})"
    end

    def users_active_tab?
      params[:active].present?
    end
    helper_method :users_active_tab?

    def users_inactive_tab?
      params[:inactive].present?
    end
    helper_method :users_inactive_tab?

    def users_mentors_tab?
      params[:mentors].present?
    end
    helper_method :users_mentors_tab?

    def users_mentees_tab?
      params[:mentees].present?
    end
    helper_method :users_mentees_tab?

    private

    def specific_ids_if_specified(relation)
      if params[:user_ids].present?
        relation.where(id: params[:user_ids].split(','))
      else
        relation
      end
    end

    def search_clause(relation)
      if params[:query].present?
        organizations = Organization.basic_search(name: params[:query])
        if organizations.present?
          organization_ids = organizations.collect(&:id)

          return relation.where(organization_id: organization_ids)
        end

        teams = Team.basic_search(name: params[:query])
        if teams.present?
          team_ids = teams.collect(&:id)

          return relation.where('users.id IN(SELECT user_id FROM team_members WHERE team_id IN(?))', team_ids)
        end

        # see docs at https://github.com/textacular/textacular
        # #TODO include admin_notes as well?

        user_ids_by_name = User.fuzzy_search(name: params[:query]).all.collect(&:id)
        user_ids_by_email = User.fuzzy_search(email: params[:query]).all.collect(&:id)

        relation.where(id: [user_ids_by_name + user_ids_by_email].flatten)
      else
        relation
      end
    end

    # admin/users#index header/type tab
    def active_clause(relation)
      if users_active_tab?
        relation.active_recipient
      else
        relation
      end
    end

    # admin/users#index header/type tab
    def inactive_clause(relation)
      if users_inactive_tab?
        user_ids = User.active_recipient.pluck(:id)

        relation.where.not(id: user_ids)
      else
        relation
      end
    end

    # admin/users#index header/type tab
    def mentors_clause(relation)
      if users_mentors_tab?
        relation.where('users.id IN(SELECT mentor_user_id FROM organizational_mentorships)')
      else
        relation
      end
    end

    # admin/users#index header/type tab
    def mentees_clause(relation)
      if users_mentees_tab?
        relation.where('users.id IN(SELECT mentee_user_id FROM organizational_mentorships)')
      else
        relation
      end
    end

    def visible_by_role_clause(relation)
      if current_user.system_admin?
        relation
      elsif current_user.leaderbits_employee_with_access_to_any_organization?
        relation.where(organization_id: current_user.leaderbits_employee_with_access_to_organizations.collect(&:id))
      else
        raise
      end
    end

    def set_user
      @user = User.find_by_uuid!(params[:id])
    end

    #TODO move this logic into dry-transaction interactors
    # def user_params
    #   if params[:user] && params[:user][:password].blank?
    #     params[:user].delete(:password)
    #     params[:user].delete(:password_confirmation)
    #   end
    #
    #   params.require(:user).permit(
    #     :time_zone,
    #     :name,
    #     :phone,
    #     :email,
    #     :password,
    #     :leaderbits_sending_enabled,
    #     :password_confirmation,
    #     :organization_id,
    #     :schedule_id,
    #     :hour_of_day_to_send,
    #     :day_of_week_to_send
    #   )
    # end
  end
end

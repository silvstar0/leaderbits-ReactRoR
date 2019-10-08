# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ActsAsUnobtrusiveFlash

  # Security note: controllers with no-CSRF protection must disable the Devise fallback, see github
  acts_as_token_authentication_handler_for User, fallback: :none

  include Pundit
  before_action :ensure_all_onboarding_steps_completed_for_active_recipient
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_proper_audited_status

  #layout :layout_by_resource
  around_action :user_time_zone, if: :current_user
  helper_method :resource, :resource_name, :devise_mapping

  def individual_engagement_request?
    params['uuid'].present?
  end
  helper_method :individual_engagement_request?

  def set_proper_audited_status
    Audited.auditing_enabled = false
  end

  def onboaring_steps_to_paths
    {
      User::OnboardingSteps::WELCOME_VIDEO_ONBOARDING_STEP => welcome_video_path,
      User::OnboardingSteps::LEADER_STRENGTH_FINDER_ONBOARDING_STEP => step2_path,
      User::OnboardingSteps::TEAM_SURVEY_360_ONBOARDING_STEP => step3_path,
      User::OnboardingSteps::ORGANIZATIONAL_MENTORSHIP_ONBOARDING_OPTIONAL_STEP => step4_path
    }
  end
  helper_method :onboaring_steps_to_paths


  #NOTE: welcome video step is not mentioned here, that's because there is no actionable link that points directly to welcome video step
  # user is redirected to it automatically
  def onboaring_steps_to_titles
    {
      User::OnboardingSteps::LEADER_STRENGTH_FINDER_ONBOARDING_STEP => 'Take Leadership Strengths Finder',
      User::OnboardingSteps::TEAM_SURVEY_360_ONBOARDING_STEP => 'Send 360 Team Survey',
      User::OnboardingSteps::ORGANIZATIONAL_MENTORSHIP_ONBOARDING_OPTIONAL_STEP => 'Select Mentee'
    }
  end
  helper_method :onboaring_steps_to_titles

  def url_to_onboarding_step(url)
    uri = URI.parse url
    #User::OnboardingSteps::ORGANIZATIONAL_MENTORSHIP_ONBOARDING_STEP
    #User::OnboardingSteps::LEADER_STRENGTH_FINDER_ONBOARDING_STEP
    #User::OnboardingSteps::TEAM_SURVEY_360_ONBOARDING_STEP
    if uri.path.start_with?('/welcome')
      User::OnboardingSteps::WELCOME_VIDEO_ONBOARDING_STEP
    else
      raise("can not interpret #{url}")
    end
  end

  def load_user_and_team_survey_results
    # The reason why we check user_id param here is because we want to enable this "preview" functionality for admins
    @user = if params[:user_id].present?
              raise if !current_user.system_admin? && !current_user.leaderbits_employee_with_access_to_any_organization?

              User.find_by_uuid(params[:user_id]) || User.find(params[:user_id])
            else
              current_user
            end

    combined_results_by_question = @user.combined_results_by_question

    @combined_results_by_question = if combined_results_by_question.present? && combined_results_by_question.first.last[:answers].collect(&:anonymous_survey_participant_id).uniq.count >= Rails.configuration.minimum_number_of_completed_surveys_to_display
                                      combined_results_by_question
                                    else
                                      []
                                    end
  end

  #return new instance of VacationMode in case new vacation mode could be created for user at the moment
  def load_new_vacation_mode
    vacation_mode_with_future_end_at = VacationMode.where(user: current_user).where('ends_at > ?', Time.now)
    return if vacation_mode_with_future_end_at.exists?

    args = {}
    # know a better method? Fix it
    # updating react calendar component from capybara specs is even worse
    if Rails.env.test?
      args = { starts_at: 2.days.from_now.beginning_of_day, ends_at: 5.days.from_now.end_of_day }
    end

    current_user.vacation_modes.new args
  end
  helper_method :load_new_vacation_mode

  def authenticate_in_action_cable
    #That's how user is authenticated in ActionCable channel
    #@see ApplicationCable::Connection
    cookies.signed[:uuid] = current_user.uuid
  end

  def unread_entry_groups_count
    #user = User.find_by_uuid(uuid)
    #relation.where('users.id IN(SELECT mentee_user_id FROM leaderbit_employee_mentorships WHERE mentor_user_id = ?)', user.id)
    @unread_entry_groups_count ||= begin
      if LeaderbitEmployeeMentorship.where(mentor_user_id: current_user.id).exists?
        EntryGroup
          .exclude_discarded_users
          .where('entry_groups.id IN(SELECT entry_group_id FROM entries WHERE discarded_at IS NULL)') #TODO do we still need this? Seems like old migration artefact
          .where('users.id IN(SELECT mentee_user_id FROM leaderbit_employee_mentorships WHERE mentor_user_id = ?)', current_user.id)
          .unseen_by_user(current_user)
          .count
      else
        EntryGroup
          .exclude_discarded_users
          .where('entry_groups.id IN(SELECT entry_group_id FROM entries WHERE discarded_at IS NULL)') #TODO do we still need this? Seems like old migration artefact
          .yield_self(&method(:if_no_special_parameter_or_filtering_is_set_clause))
          .unseen_by_user(current_user)
          .count

      end
    end
  end
  helper_method :unread_entry_groups_count

  #TODO-low are we risking anything here? user may potentially type uuid manually
  #TODO looks very duplicated to focused_by_user_clause_if_set
  def specific_user_clause_if_set(relation)
    #F I X M E security
    #TODO rename to user_uuid?
    if uuid = params.dig(:user_uuid)
      return relation if uuid.blank?

      user = User.find_by_uuid(uuid)
      relation.where(user_id: user.id)
    else
      relation
    end
  end

  #TODO-High - rename because it is reused in multiple places
  def if_no_special_parameter_or_filtering_is_set_clause(relation)
    return relation if params.dig(:user_uuid).present?
    return relation if params.dig(:mentor_user_uuid).present?
    return relation if params.dig(:leaderbit_id).present?

    #TODO add missing scope check - whether "My Team X" has been selected in Engagement screen

    relation_by_role = if current_user.system_admin? || LeaderbitEmployeeMentorship.where(mentor_user: current_user).exists?
                         relation.all
                       #NOTE: you don't need to think about use cases like(employee-mentor & also part of a team(as of May 2019 team name was *The cool kids 2*)
                       # we handled that use case by assigning everyone in that team has employee-mentors who are also from that team
                       # @see 20190528161849 migration
                       #elsif LeaderbitEmployeeMentorship.where(mentor_user: current_user).exists?
                       #  relation.where("entry_groups.user_id IN (SELECT mentee_user_id FROM leaderbit_employee_mentorships WHERE mentor_user_id = ?)", current_user.id)
                       elsif current_user.c_level?
                         relation.where("entry_groups.user_id IN (SELECT id FROM users WHERE organization_id = ?)", current_user.organization_id)
                       else
                         relation.visible_in_my_teams(current_user)
                           .where('entry_groups.id IN(SELECT entry_group_id FROM entries WHERE visible_to_my_peers IS TRUE AND discarded_at IS NULL)')
                       end

    query = <<-SQL.squish
      user_id IN(SELECT mentee_user_id FROM organizational_mentorships WHERE mentor_user_id = ?)
        OR user_id IN(SELECT mentor_user_id FROM organizational_mentorships WHERE mentee_user_id = ?)
    SQL

    relation_by_role
      .or(EntryGroup.where('entry_groups.id IN(SELECT entry_group_id FROM entries WHERE discarded_at IS NULL)').where('user_id = ?', current_user.id).joins(:user))
      .or(EntryGroup.where('entry_groups.id IN(SELECT entry_group_id FROM entries WHERE discarded_at IS NULL)').where(query, current_user.id, current_user.id).joins(:user))
      .includes(:leaderbit, entries: [:user, replies: { user: :organization }], user: %i[organization schedule])
  end

  def specific_leaderbits_employee_mentor_user_clause_if_set(relation)
    if uuid = params.dig(:mentor_user_uuid)
      return relation if uuid.blank?

      user = User.find_by_uuid(uuid)
      relation.where('users.id IN(SELECT mentee_user_id FROM leaderbit_employee_mentorships WHERE mentor_user_id = ?)', user.id)
    else
      relation
    end
  end

  def specific_leaderbit_clause_if_set(relation)
    leaderbit_id = params.dig(:leaderbit_id)
    if leaderbit_id.present?
      relation.where(leaderbit_id: leaderbit_id)
    else
      relation
    end
  end

  # Method used by sessions controller to sign out a user.
  # Notice that differently from +after_sign_in_path_for+ this method
  # receives a symbol with the scope, and not the resource.
  #
  # By default it is the root_path.
  def after_sign_out_path_for(_resource_or_scope)
    # scope = Devise::Mapping.find_scope!(resource_or_scope)
    # router_name = Devise.mappings[scope].router_name
    # context = router_name ? send(router_name) : self
    # context.respond_to?(:root_path) ? context.root_path : "/"

    # the goal of this method being redefined is to get rid of "You need to sign in or sign up before continuing." flash message
    # that is displayed right after you sign out(root path is authorization-restricted).
    new_user_session_path
  end

  # NOTE: "for_leaders" part in the method name. There is a user role for users who do not receive leaderbits and don't need to watch the welcome video.
  def ensure_all_onboarding_steps_completed_for_active_recipient
    return unless user_signed_in?
    return unless request.get?

    onboarding = UserOnboarding.new(current_user)
    onboarding_completed = onboarding.last_step == current_user.last_completed_onboarding_step_for_active_recipient
    return if onboarding_completed

    #NOTE: you may need to rethink and retest this check in case we ever have a user with disabled leaderbits sending & enabled welcome video onboarding step
    return unless current_user.leaderbits_sending_enabled?

    #Artefact that was introduced during Nick's work on #167231965
    #the goal of this return is to keep the workflow for all the existing users with some started/completed challenges unaffected
    # and not forcing them back to skipped/missing onboarding steps. That decision was approved by Fabiana
    return if LeaderbitLog.where(user: current_user).exists?

    #c-level, completed leader_strength_finder_onboarding_step but no leaderbit logs(as of 22 Jul 2019)
    return if current_user.email == 'ben@bimobject.com'

    #just an old user
    return if current_user.email == 'csaba.gal@bimobject.com'

    # invited mentee accepts invitation, skip welcome video check - this is where he is redirected afterwards anyways
    return if action_name == 'accept' && controller_name == 'organizational_mentorships'

    # this might be needed in case Joel assigned some schedule to *technical user* and instead of forcing him into watching welcome video
    # let him at least see that *See details* entry link from email first
    return if action_name == 'show' && controller_name == 'entry_groups'

    return if devise_controller?

    return if current_user.technical_user_progress_report_recipient?

    #avoiding infinite loop
    white_list_paths = onboaring_steps_to_paths.values
    return if white_list_paths.any? { |path| request.path.include? path }

    #solves an issue when leaderbits_sending_enabled=TRUE but all onboarding steps are disabled
    return if onboarding.first_step.blank?

    step_to_redirect_to = if current_user.last_completed_onboarding_step_for_active_recipient.blank?
                            onboarding.first_step
                          else
                            onboarding.next_step_after current_user.last_completed_onboarding_step_for_active_recipient
                          end
    redirect_to onboaring_steps_to_paths.fetch(step_to_redirect_to)
  end

  # this order condition is extracted because
  # * it is shared between various actions&controllers
  # * it could be improved. updated_at would have been better but it is updated frequently by various cache invalidation callbacks TODO
  def newest_first_order
    { created_at: :desc }
  end

  private

  def configure_permitted_parameters
    %i[sign_up organization_update].each do |action|
      devise_parameter_sanitizer.permit(action, keys: %i[name email password password_confirmation time_zone])
    end
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end

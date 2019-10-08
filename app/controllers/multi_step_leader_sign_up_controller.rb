# frozen_string_literal: true

class MultiStepLeaderSignUpController < ApplicationController
  before_action :authenticate_user!

  # STEP 2
  #NOTE: if step is enabled it is mandatory, leader has to fill in the survey
  def leader_strength_finder
    @survey = Survey.leadership_strangths_finder
    @questions = @survey
                   .questions
                   .order(position: :asc)


    # The reason why we check user_id param here is because we want to enable this "preview" functionality for admins
    @user = if params[:user_id].present?
              raise if !current_user.system_admin? && !current_user.leaderbits_employee_with_access_to_any_organization?

              User.find(params[:user_id])
            else
              current_user
            end

    respond_to do |format|
      format.html { render layout: 'survey' }
    end
  end

  # STEP 3
  #NOTE: if step is enabled it is mandatory, leader has to fill in some participants
  def team_survey_360
    @survey = Survey.leadership_strangths_finder

    if params[:new].present?
      @anonymous_survey_participant = AnonymousSurveyParticipant.new
    elsif params[:edit].present?
      @anonymous_survey_participant = current_user.anonymous_survey_participants.find(params[:edit])
    end

    respond_to do |format|
      format.html { render layout: 'survey' }
    end
  end

  #TODO think about use case when user manually accessed multi-step process, what challenge will he start after another "Begin Challenge" click
  # STEP 4
  def mentorship
    if params[:new].present?
      @organizational_mentorship = OrganizationalMentorship.new
    elsif params[:edit].present?
      @organizational_mentorship = OrganizationalMentorship.where(mentor_user_id: current_user.id, id: params[:edit]).first!
    end

    #NOTE this step is automatically marked as completed because it is optional
    # there is no need to redirect user back to it if browser session is lost
    current_user.update_last_completed_onboarding_step User::OnboardingSteps::ORGANIZATIONAL_MENTORSHIP_ONBOARDING_OPTIONAL_STEP

    respond_to do |format|
      format.html { render layout: 'survey' }
    end
  end
end

# frozen_string_literal: true

class AnonymousSurveyParticipantsController < ApplicationController
  before_action :set_anonymous_survey_participant, only: %i[update destroy]

  def create
    @anonymous_survey_participant = AnonymousSurveyParticipant.new(anonymous_survey_participant_params)
    @anonymous_survey_participant.added_by_user = current_user

    if @anonymous_survey_participant.save
      unobtrusive_flash.regular type: :notice, message: "#{anonymous_survey_participant_params[:name]} has been added to the team."

      current_user.update_last_completed_onboarding_step User::OnboardingSteps::TEAM_SURVEY_360_ONBOARDING_STEP

      redirect_to controller: params[:controller_name], action: params[:action_name]
    else
      params[:new] = 1

      # in case of step3 this is unnecessary but the code is simpler
      load_user_and_team_survey_results

      render "#{params[:controller_name]}/#{params[:action_name]}"
    end
  end

  def update
    if @anonymous_survey_participant.update(anonymous_survey_participant_params)
      unobtrusive_flash.regular type: :notice, message: "#{@anonymous_survey_participant.name} has been updated."
      redirect_to controller: params[:controller_name], action: params[:action_name]
    else
      params[:edit] = @anonymous_survey_participant.id

      # in case of step3 this is unnecessary but the code is simpler
      load_user_and_team_survey_results

      render "#{params[:controller_name]}/#{params[:action_name]}"
    end
  end

  def destroy
    @anonymous_survey_participant.destroy

    unobtrusive_flash.regular type: :notice, message: "#{@anonymous_survey_participant.name} is no longer part of the team."
    redirect_to controller: params[:controller_name], action: params[:action_name]
  end

  private

  def set_anonymous_survey_participant
    @anonymous_survey_participant = AnonymousSurveyParticipant.find(params[:id])
  end

  def anonymous_survey_participant_params
    params.fetch(:anonymous_survey_participant).permit(%i[email name role])
  end
end

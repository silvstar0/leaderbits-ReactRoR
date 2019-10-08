# frozen_string_literal: true

class AnswersController < ApplicationController
  # could be done "anonymously" too
  #skip_before_action :authenticate_user!, only: [:create]

  def create
    @survey = Survey.find params[:survey_id]

    if anonymous_team_member?
      create_for_anonymous_user
    else
      create_for_leader
    end
  end

  private

  def create_for_leader
    params[:answers].each do |question_id, answer_value|
      question = Question.find(question_id)

      question.answers.create!(user: current_user, params: { value: answer_value })
    end

    onboarding = UserOnboarding.new current_user
    next_step = onboarding.next_step_after User::OnboardingSteps::LEADER_STRENGTH_FINDER_ONBOARDING_STEP
    next_step_path = if next_step.present?
                       onboaring_steps_to_paths.fetch(next_step)
                     else
                       challenges_begin_first_path
                     end

    current_user.update_last_completed_onboarding_step User::OnboardingSteps::LEADER_STRENGTH_FINDER_ONBOARDING_STEP

    redirect_to next_step_path, notice: "Survey data saved" #TODO extract
  end

  def create_for_anonymous_user
    #TODO params[:id] readability need to be enhanced for better clarity
    anonymous_survey_participant = AnonymousSurveyParticipant.find_by_uuid!(params[:id])

    params[:answers].each do |question_id, answer_value|
      question = Question.find(question_id)
      question
        .answers
        .create!(anonymous_survey_participant_id: anonymous_survey_participant.id, params: { value: answer_value })
    end

    completed_by_team_members_quantity = Answer
                                           .where('anonymous_survey_participant_id IN(SELECT id FROM anonymous_survey_participants WHERE added_by_user_id = ?)', anonymous_survey_participant.added_by_user.id)
                                           .pluck(:anonymous_survey_participant_id)
                                           .uniq
                                           .count

    if completed_by_team_members_quantity >= Rails.configuration.minimum_number_of_completed_surveys_to_display
      UserMailer
        .with(user: anonymous_survey_participant.added_by_user)
        .anonymous_survey_completed
        .deliver_now
    end

    #TODO params[:id] readability need to be enhanced for better clarity
    redirect_to anonymous_survey_completed_surveys_path(anonymous_survey_participant_id: params[:id])
  end

  def anonymous_team_member?
    #TODO could this be more explicit and readable?
    params[:id].present?
  end
end

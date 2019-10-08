# frozen_string_literal: true

class SurveysController < ApplicationController
  #NOTE: :authenticate_user! is purposely missing

  def participate_anonymously
    uuid = params[:anonymous_survey_participant_id]
    @anonymous_survey_participant = AnonymousSurveyParticipant.find_by_uuid! uuid

    @survey = Survey.for_follower.where(anonymous_survey_participant_role: @anonymous_survey_participant.role).first!

    @already_voted_at = Answer.where(anonymous_survey_participant: @anonymous_survey_participant).last&.created_at

    respond_to do |format|
      format.html { render layout: 'devise' }
    end
  end

  def anonymous_survey_completed
    #NOTE: do not rename this param since it is already present in sent emails
    # upd. "in sent emails?" sounds strange because use is redirected to this action after completing the survey form, not from email link
    @anonymous_survey_participant = AnonymousSurveyParticipant.find_by_uuid! params[:anonymous_survey_participant_id]

    respond_to do |format|
      format.html { render layout: 'devise' }
    end
  end
end

# frozen_string_literal: true

class ProgressReportRecipientsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_progress_report_recipient, only: %i[update destroy]

  def create
    email = params.dig(:progress_report_recipient, :email)
    name = params.dig(:progress_report_recipient, :name)

    user = User.find_by_email(email)
    if user.blank?
      user = User.new(email: email,
                      name: name,
                      #NOTE: it is very important to create new progress report users with blank schedule
                      # otherwise we won't be able to distinguish them from the rest of the real users
                      schedule: nil,
                      #technically these users don't need timezones at all
                      time_zone: current_user.time_zone,
                      hour_of_day_to_send: current_user.organization.hour_of_day_to_send,
                      day_of_week_to_send: current_user.organization.day_of_week_to_send,
                      leaderbits_sending_enabled: false,
                      created_by_user_id: current_user.id,

                      #these 4 could probably just be nil instead
                      goes_through_leader_welcome_video_onboarding_step: false,

                      goes_through_leader_strength_finder_onboarding_step: false,
                      goes_through_team_survey_360_onboarding_step: false,
                      goes_through_organizational_mentorship_onboarding_step: false,

                      organization: current_user.organization)

      def user.password_required?
        false
      end
      user.save!

      #user.discard # so that they won't receive leaderbits
    end

    @progress_report_recipient = ProgressReportRecipient.new(progress_report_recipient_params)
    @progress_report_recipient.user = user
    @progress_report_recipient.added_by_user = current_user

    if @progress_report_recipient.save
      unobtrusive_flash.regular type: :notice, message: "#{name} has been added to the team."
      redirect_to controller: params[:controller_name], action: params[:action_name]
    else
      params[:new] = 1

      render "#{params[:controller_name]}/#{params[:action_name]}"
    end
  end

  def update
    if @progress_report_recipient.update(progress_report_recipient_params)
      unobtrusive_flash.regular type: :notice, message: "#{@progress_report_recipient.user.name} has been updated."
      redirect_to controller: params[:controller_name], action: params[:action_name]
    else
      params[:edit] = @progress_report_recipient.id


      render "#{params[:controller_name]}/#{params[:action_name]}"
    end
  end

  def destroy
    @progress_report_recipient.destroy

    unobtrusive_flash.regular type: :notice, message: "#{@progress_report_recipient.name} is no longer part of the team."
    redirect_to controller: params[:controller_name], action: params[:action_name]
  end

  private

  def set_progress_report_recipient
    @progress_report_recipient = ProgressReportRecipient.find(params[:id])
  end

  def progress_report_recipient_params
    params.fetch(:progress_report_recipient).permit(%i[frequency])
  end
end

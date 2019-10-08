# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  add_template_helper ApplicationHelper
  add_template_helper MailerHelper
  include ActionView::Helpers::TextHelper

  layout 'mailer_minimalist'

  #NOTE: this mailer action is triggered manually by admin
  def user_lifetime_progress_dump
    @user = params.fetch(:user)

    @leaderbit_logs = @user.lifetime_completed_leaderbit_logs

    #NOTE: actual "See details" link URLs are generated right in the template
    mail(to: @user.as_email_to, subject: "#{@user.first_name} you're progressing as a leader")
  end

  #NOTE: this mailer action is triggered manually by admin
  # admin manually specifies recipient email!
  def organization_lifetime_progress_dump
    @organization = params.fetch(:organization)

    @leaderbit_logs = @organization.lifetime_completed_leaderbit_logs

    mail(to: params.fetch(:recipient_email), subject: "#{@organization.name} : Progress Report")
  end

  def active_recipients_with_missing_upcoming_leaderbit
    @users = params.fetch(:users)

    mail(to: Rails.configuration.fabiana_email,
         cc: [Rails.configuration.allison_email, Rails.configuration.nick_email, 'jake@moderncto.io'],
         subject: "Warning: not enough LeaderBits to send to #{pluralize(@users.count, 'user')}")
  end

  def active_recipients_with_missing_leaderbit_employee_mentor
    @users = params.fetch(:users)

    mail(to: Rails.configuration.fabiana_email,
         cc: [Rails.configuration.courtney_email, Rails.configuration.nick_email],
         subject: "Warning: #{pluralize(@users.count, 'leader')} don't have LeaderBits employee-mentors")
  end

  def notify_joel_about_new_inactive_leaderbit
    @leaderbit = params.fetch(:leaderbit)
    @created_by = params.fetch(:created_by)
    @user = User.find_by_email(Rails.configuration.joel_email)

    mail(to: @user.as_email_to,
         cc: [@created_by.as_email_to, Rails.configuration.nick_email, Rails.configuration.fabiana_email],
         subject: %(New LeaderBit need approvement – "#{@leaderbit.name}" created by #{@created_by.name}"))
  end
end

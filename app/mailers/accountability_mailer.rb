# frozen_string_literal: true

class AccountabilityMailer < ApplicationMailer
  add_template_helper ApplicationHelper
  add_template_helper MailerHelper
  layout 'mailer_minimalist'

  #frequency could be weekly, bi-monthly, monthly
  #recipients are #progress_report_recipients
  def user_is_progressing_as_leader
    @user = params.fetch(:user) #leader

    #the reason why it is injected from outside is because otherwise mailer preview is really complicated
    @leaderbit_logs = params.fetch(:leaderbit_logs)
    if @leaderbit_logs.blank?
      #if it reached there is something wrong in UserIsProgressingAsLeaderMailerJob or mailer preview action
      raise "user_is_progressing_as_leader doesnt have completed logs to send #{@user.inspect}"
    end

    #note that is most likely "technical"/discarded for-entry-show view only user
    @recipient_user = params.fetch(:recipient_user)


    #NOTE: actual "See details" link URLs are generated right in the template
    mail(to: @recipient_user.as_email_to, subject: "#{@user.first_name} is progressing as a leader")
  end

  def monthly_progress_report
    @user = params.fetch(:user)

    @completed_leaderbit_logs = LeaderbitLog
                                  .completed
                                  .where(user: @user)
                                  .includes(:leaderbit)
                                  .where(updated_at: 4.weeks.ago..Time.now)
                                  .order(updated_at: :desc)
    #NOTE: actual "See details" link URLs are generated right in the template

    if @completed_leaderbit_logs.blank?
      @current_leaderbit_in_progress = @user.current_leaderbit_in_progress

      if @current_leaderbit_in_progress.blank?
        @last_sent_leaderbit = @user
                                 .user_sent_scheduled_new_leaderbits
                                 .includes(:resource)
                                 .last
                                 .resource || raise("can not get last sent leaderbit for #{@user.id}")
      end
    end

    subject = if @completed_leaderbit_logs.present?
                "#{@user.first_name} you're progressing as a leader"
              else
                "#{@user.first_name} you've had no progress this month"
              end

    mail(to: @user.as_email_to, subject: subject)
  end

  def dont_quit
    @user = params.fetch(:user)
    mail(to: @user.as_email_to, subject: "#{@user.first_name}, a great leader is one who invests in themselves.")
  end

  def user_is_trying_to_hide
    @user = params.fetch(:user)

    #NOTE: why we pass name & email directly and not just an progress_report_recipient instance:
    # mailer action is triggered *after* recipient is destroyed + mailer delivery job should be postponable
    @recipient_name = params.fetch(:recipient_name)
    @recipient_email = params.fetch(:recipient_email)

    to = %(#{@recipient_name} <#{@recipient_email}>)

    mail(to: to, subject: "#{@user.first_name} is trying to hide")
  end

  def user_is_slacking_off
    @user = params.fetch(:user)
    @progress_report_recipient = params.fetch(:progress_report_recipient)

    to = %(#{@progress_report_recipient.name} <#{@progress_report_recipient.email}>)
    mail(to: to, cc: @user.as_email_to, subject: "#{@user.first_name} is slacking off")
  end
end

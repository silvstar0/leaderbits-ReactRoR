# frozen_string_literal: true

class LeaderbitMailer < ApplicationMailer
  add_template_helper ApplicationHelper
  add_template_helper MailerHelper

  def new_leaderbit
    @user = params.fetch(:user)
    @leaderbit = params.fetch(:leaderbit)

    #NOTE: see ScheduledNewLeaderbitMailerJob to understand the workflow of 1st leaderbit for leader
    # Order is the following:
    # 1) *this* mail is sent
    # 2) UserSentScheduledNewLeaderbit is created.
    # so it's safe to check for received_uniq_leaderbit_ids here
    @user_received_leaderbit_ids = @user.received_uniq_leaderbit_ids

    subject = @user_received_leaderbit_ids.blank? ? 'Welcome to LeaderBits.io' : 'New LeaderBit Challenge!'

    mail(to: @user.as_email_to, subject: subject) do |format|
      format.html { render layout: 'mailer_minimalist' }
    end
  end

  def uncompleted_leaderbit_reminder
    @user = params.fetch(:user)
    @leaderbit = params.fetch(:leaderbit)

    mail(to: @user.as_email_to, subject: 'Incomplete challenge') do |format|
      format.html { render layout: 'mailer_minimalist' }
    end
  end

  def boomerang
    @leaderbit = params.fetch(:leaderbit)
    @user = params.fetch(:user)

    #TODO why does it limit? why 2?
    @user_leaderbit_entries = Entry
                                .where(leaderbit_id: @leaderbit.id, user_id: @user.id)
                                .order(updated_at: :desc)
                                .limit(2)

    mail(to: @user.as_email_to, subject: "Boomerang #{@leaderbit.name}")
  end
end

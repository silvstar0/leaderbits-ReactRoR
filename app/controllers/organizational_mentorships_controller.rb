# frozen_string_literal: true

class OrganizationalMentorshipsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_organizational_mentorship, only: %i[update destroy]

  def create
    result = FindOrCreateNewOrganizationalMentorship.create_and_return email: organizational_mentorship_params.fetch(:email),
                                                                       name: organizational_mentorship_params.fetch(:name),
                                                                       current_user: current_user

    if result
      unobtrusive_flash.regular type: :notice, message: "#{organizational_mentorship_params.fetch(:name)} has been added to the team."
      redirect_to controller: params[:controller_name], action: params[:action_name]
    else
      params[:new] = 1

      render "#{params[:controller_name]}/#{params[:action_name]}"
    end
  end

  def update
    raise 'Updating of existing user mentees is prohibited. Use delete & re-create as a workaround'
  end

  def destroy
    @organizational_mentorship.destroy

    unobtrusive_flash.regular type: :notice, message: "#{@organizational_mentorship.mentee_user.name} is no longer part of the team."
    redirect_to controller: params[:controller_name], action: params[:action_name]
  end

  def accept
    organizational_mentorship = OrganizationalMentorship.find params[:id]

    authorize organizational_mentorship

    if organizational_mentorship.accepted_at.blank?
      organizational_mentorship.touch(:accepted_at)
      # this is needed for a proper sending anomaly detection. Excluding new invited users until they accept an invitation
      organizational_mentorship.mentee_user.update_column(:leaderbits_sending_enabled, true)

      UserMailer
        .with(organizational_mentorship_id: organizational_mentorship.id)
        .mentee_accepted_invitation
        .yield_self { |mail_message| Rails.env.test? || Rails.env.development? ? mail_message.deliver_now : mail_message.deliver_later }

      user = organizational_mentorship.mentee_user

      leaderbit = user.next_leaderbit_to_send
      if leaderbit.present?
        Rails.logger.info "user_id=#{user.id} Scheduling sending of *#{leaderbit.name}* leaderbit to *#{user.email}"

        #NOTE: IMPORTANT if you change it to perform_now it will break the following redirect logic so please don't unless you know what you're doing.
        ScheduledNewLeaderbitMailerJob.perform_later(user.id, leaderbit.id)
      else
        # mostly just future proofing it
        Rollbar.scoped(user_id: user.id, organizational_mentorship_id: organizational_mentorship.id) do
          Rollbar.error("got no leaderbit to send to new mentee. Figure it out because user is stuck")
        end
      end
    end

    if current_user.user_sent_scheduled_new_leaderbits.exists?
      unobtrusive_flash.regular type: :notice, message: "Invitation has been accepted"
      redirect_to dashboard_path
      return
    end

    #NOTE: if user reached this step we'll need to send his 1st LeaderBit right away
    # why it works like that? Because that's the closest to the existing onboarding workflow and because it make sense.
    # User's mentor has most likely already received the his LeaderBit(unless sending is disabled) so they both will be on the same page.
    # The only tricky issue with this approach is when invitation is accepted soon before scheduled LeaderBit send time

    sign_out current_user
  end

  private

  def set_organizational_mentorship
    @organizational_mentorship = OrganizationalMentorship.find(params[:id])
  end

  def organizational_mentorship_params
    params.fetch(:organizational_mentorship).permit(%i[email name role])
  end
end

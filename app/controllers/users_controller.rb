# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: %i[create update]

  before_action :set_organization, only: %i[index new create edit update]
  before_action :set_user, only: %i[show edit update destroy]

  def show
    # NOTE @user could be current_user or just another user you have access to
    authorize @user

    #TODO-low add pagination?
    @entry_groups = EntryGroup
                      .exclude_discarded_users
                      .where('entry_groups.id IN(SELECT entry_group_id FROM entries WHERE discarded_at IS NULL)')
                      .yield_self(&method(:if_no_special_parameter_or_filtering_is_set_clause))
                      .order(created_at: :desc)
                      .yield_self(&method(:reject_entry_groups_from_other_users))
  end

  def edit
    #TODO this should be limited to "you're only allowed to update yourself from now on"
    authorize @user

    # the reason of this assigning is not to confuse/surprise user with blank fields. Do not remove
    @user.hour_of_day_to_send ||=  @user.organization.hour_of_day_to_send
    @user.day_of_week_to_send ||=  @user.organization.day_of_week_to_send

    #TODO why is it here?
    unobtrusive_flash.fetch_flash_message_from_session_if_present(session)
  end

  def update
    @user = User.find_by_uuid(params[:id])
    authorize @user

    @user.attributes = user_params

    if @user.valid?
      @user.save!

      respond_to do |format|
        format.html do
          # as of Nov 2018 those are requests from Accountability page
          # upd. May 2019 - not anymore, user profile updates as well
          # TODO-High make it more user friendly
          redirect_to request.referer
        end

        format.js do
          #TODO-High dead code path? remote updates seems to be gone
          unobtrusive_flash.set_after_js_redirect_flash_message session, 'User has been updated.'
          render js: "window.location.href=#{after_user_save_redirect_path.to_json}"
        end
      end
    end
  end

  def reset_password
    raise("in this case user doesn't need to reset it. He can just enter (a new) one") unless current_user.existing_password_exists?

    current_user.send_reset_password_instructions

    #NOTE: why we purposely sign him out here:
    # because that's devise works by default unless you want to go crazy with patching it or digging deep into implementation details.
    sign_out

    redirect_to new_session_path(:user), notice: 'You will receive an email with instructions about how to reset your password in a few minutes.'
  end

  private

  #fixes #166555540
  def reject_entry_groups_from_other_users(relation)
    #the reason why we iterate here and not extracting it to higher level SQL check is because it is overwritten by #if_no_special_parameter_or_filtering_is_set_clause
    # and returns all the records of your mentees anyway. Know a clean & reliable alternative fix? Go for it

    relation.select { |entry_group| entry_group.user_id == @user.id }
  end

  def after_user_save_redirect_path
    # because otherwise it is hard to guess what's the redirect path should be
    # because user could have different roles, in different teams
    # upd. what? looks like we don't need it anymore #TODO
    edit_user_path(@user.uuid)

    # hash = role_hashes.detect { |hash| hash['team_id'] }
    # # NOTE: if role is leader of leaders then it is not related to any specific team
    # team = hash ? Team.find_by_id(hash['team_id']) : nil
    #
    # if team.present?
    #   organization_team_users_path(@user.organization, team)
    # else
    #   organization_users_path(@user.organization)
    # end
  end

  def user_params
    params.require(:user).permit(:name,
                                 :email,
                                 :notify_me_if_i_missing_2_weeks_in_a_row,
                                 :notify_observer_if_im_trying_to_hide,
                                 :goes_through_leader_welcome_video_onboarding_step,
                                 :goes_through_leader_strength_finder_onboarding_step,
                                 :goes_through_team_survey_360_onboarding_step,
                                 :goes_through_organizational_mentorship_onboarding_step,
                                 #not real attribute. upd what does it mean? do we still need it? todo
                                 :progress_report_recipient_id,
                                 :time_zone,
                                 :hour_of_day_to_send,
                                 :day_of_week_to_send).yield_self do |enhanced_user_params|
      unless enhanced_user_params[:progress_report_recipient_id].nil?
        new_value = enhanced_user_params[:progress_report_recipient_id] == '' ? nil : enhanced_user_params.fetch(:progress_report_recipient_id)

        if new_value.present?
          #minimalist pundit scope check
          new_value = current_user.progress_report_recipients.find(new_value).id
        end

        enhanced_user_params[:notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks] = new_value
        enhanced_user_params.delete(:progress_report_recipient_id)
      end
      enhanced_user_params
    end
  end

  def set_organization
    # @organization = Organization.where(id: params[:organization_id])
    # TODO fix it if user ever be able to manage multiple organizations
    @organization = current_user.organization
  end

  def set_user
    @user = User.find_by_uuid!(params[:id])
  end
end

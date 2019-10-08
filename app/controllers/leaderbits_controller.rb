# frozen_string_literal: true

class LeaderbitsController < ApplicationController
  include ActionView::Helpers::TextHelper # for pluralize
  before_action :authenticate_user!

  def index
    @leaderbits = Leaderbit
                    .where(id: current_user.received_uniq_leaderbit_ids)

    @completed_leaderbit_log_data = LeaderbitLog
                                      .where(user: current_user)
                                      .completed
                                      .pluck(:leaderbit_id, :updated_at)
  end

  def show
    authenticate_in_action_cable

    #User may open leaderbit page multiple times and see whole video multiple times
    #that's how we track total watch time
    #NOTE: do not remove current user prefix or we may see collisions again
    @video_session_id = "#{current_user.try(:id)}#{SecureRandom.base64.tr('+/=', 'Qrt')}"

    @leaderbit = Leaderbit.find(params[:id])
    authorize @leaderbit

    @new_entry = @leaderbit
                   .entries
                   .new(user: current_user, content: @leaderbit.entry_prefilled_text)

    @new_entry.set_default_entry_visibility

    @own_entries = current_user
                     .entries
                     .kept
                     .includes(:leaderbit)
                     .where(leaderbit_id: @leaderbit.id)
                     .order(created_at: :desc)

    @community_entries = @leaderbit
                           .entries
                           .kept
                           .where(visible_to_community_anonymously: true)
                           .order(created_at: :desc)
  end

  #NOTE: you may remove this action as unnecessary if links to this action are replaced with active #start_leaderbit_path links
  #NOTE: keep in sync with #ensure_all_onboarding_steps_completed_for_active_recipient method
  def begin_first_challenge
    leaderbit = current_user.first_leaderbit_to_start

    if leaderbit.present?
      redirect_to start_leaderbit_path(leaderbit)
    else
      # user managed to log in before receiving his 1st leaderbit?
      redirect_to root_path
    end
  end

  #NOTE: keep in mind that this action could be requested by user AFTER leaderbit has been started(e.g. in case of "you have an unfinished" leaderbit email link)
  #NOTE: these links are sent in emails so make sure any updates here are backwards-compatible
  #NOTE: keep in sync with #ensure_all_onboarding_steps_completed_for_active_recipient method
  def start
    # NOTE in email links id is in to_param form
    @leaderbit = Leaderbit.find(params[:id])

    if policy(@leaderbit).start?
      LeaderbitLog.create_with_in_progress_status_and_assign_points! user: current_user,
                                                                     leaderbit: @leaderbit

      message = I18n.t("entries.points_earned_for_starting_challenge",
                       points_earned: pluralize(current_user.points_for_latest_event, 'point'),
                       have_points_total: pluralize(current_user.total_points, 'point'))

      unobtrusive_flash.regular type: :notice, message: message
      # unobtrusive_flash.notify jquery_selector_name: ".leaderbits-menu",
      #                          position: 'bottom center',
      #                          class_name: 'success',
      #                          message: message
    end
    redirect_to leaderbit_path(@leaderbit)
  end
end

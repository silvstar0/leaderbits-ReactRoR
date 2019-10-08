# frozen_string_literal: true

class EntriesController < ApplicationController
  include ActionView::Helpers::TextHelper
  skip_before_action :verify_authenticity_token, only: %i[toggle_like]

  before_action :authenticate_user!

  helper_method :liked?

  # NOTE: do not remove this action. We have to respect already sent emails
  # That's how simple_token_authentication handles this redirect:
  # first time user accessing this old email link, simple_token_authentication logs him in and
  # redirects to entry_group page(no need redirect with token in get param as user is already logged in)
  def show
    entry = Entry.find(params[:id])

    redirect_to entry.entry_group
  end

  def edit
    @entry = Entry.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def update
    entry = Entry.find(params[:id])
    authorize entry

    UpdateEntry.new.call(params.permit!.to_h) do |result|
      result.success do |updated_entry|
        @entry = updated_entry

        respond_to do |format|
          format.js
        end
      end
      result.failure :validate do |updated_entry|
        @entry = updated_entry

        respond_to do |format|
          format.js
        end
      end
    end
  end

  def create
    @leaderbit = Leaderbit.find(params[:leaderbit_id])

    authorize @leaderbit, :show?

    create_entry = CreateEntry.new
    create_entry.with_step_args(validate: [current_user: current_user]).call(params.permit!.to_h) do |result|
      result.success do |entry|
        # NOTE: if user deletes his entry, then posts again - we only display achievement in the first case
        if current_user.entries.count == 1
          #NOTE: the idea of displaying similar message twice is from Joel
          # that was needed because users were felt confused and still not sure what's going to happen next and when
          unobtrusive_flash.achievement id: Rails.configuration.achievements.first_completed_challenge__on_leaderbits_show

          session[Rails.configuration.display_first_completed_challenge_in_dashboard_session_key.dup.to_sym] = 1
        end

        # NOTE: if user deletes his entry, then posts again - we only display success message in the first case
        if current_user.entries.where(leaderbit: @leaderbit).count == 1
          message = I18n.t("entries.points_earned_for_posting_entry",
                           points_earned: pluralize(current_user.points_for_latest_event, 'point'),
                           have_points_total: pluralize(current_user.total_points, 'point'))

          # if displayed along with achievement unlocked, this would most likely to disappear by the time you close "achievement unlocked" modal but Joel said it is fine
          unobtrusive_flash.notify jquery_selector_name: "##{ActionView::RecordIdentifier.dom_id(entry)}",
                                   position: 'top',
                                   class_name: 'success',
                                   message: message
        end

        @entry = entry

        @new_entry = @leaderbit
                       .entries
                       .new(user: current_user, content: @leaderbit.entry_prefilled_text)

        @new_entry.set_default_entry_visibility

        respond_to do |format|
          format.js
        end
      end
      result.failure :validate do |entry|
        @entry = entry
        respond_to do |format|
          format.js
        end
      end
    end
  end

  def toggle_like
    @entry = Entry.find(params[:id])
    authorize @entry

    if current_user.favorited?(@entry)
      @entry.unliked_by current_user
      # NOTE this is not really disliked, more like "not voted" or smth
      @svg_class = 'disliked'
    else
      @entry.liked_by current_user
      @svg_class = 'liked'
    end

    UserSeenEntryGroup.find_or_create_by! user: current_user, entry_group: @entry.entry_group

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @entry = Entry.find(params[:id])

    authorize @entry

    @entry.discard

    respond_to do |format|
      format.js
    end
  end

  private

  def liked?
    if @svg_class.nil?
      raise "this is for #toggle_like action only. Set svg_class"
    end

    @svg_class == 'liked'
  end

  #TODO-low move this to dry-transaction interactors
  # def entry_params
  #   # NOTE security vulnerability:
  #   # low level/new user may create an entry and set its visibility to global before reaching the milestone level
  #   # probability? low?
  #   params.require(:entry).permit(:visibility, :content)
  # end
end

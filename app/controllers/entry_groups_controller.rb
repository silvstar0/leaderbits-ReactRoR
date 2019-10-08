# frozen_string_literal: true

class EntryGroupsController < ApplicationController
  before_action :authenticate_user!

  def index
    #TODO-low do we still need this authorize check?
    authorize Entry

    #TODO add spec that checks whether it properly handles combined OR condition for mentors

    #F I X M E - rethink security of custom filtering
    # think twice before trying to reuse and abstract this logic. It is not easy - most of logic are the same but some scopes are mutually exclusive so it's error-prone.
    @entry_groups = EntryGroup
                      .exclude_discarded_users
                      .where('entry_groups.id IN(SELECT entry_group_id FROM entries WHERE discarded_at IS NULL)')
                      .yield_self(&method(:specific_user_clause_if_set))
                      .yield_self(&method(:specific_leaderbits_employee_mentor_user_clause_if_set))
                      .yield_self(&method(:specific_leaderbit_clause_if_set))
                      .yield_self(&method(:if_no_special_parameter_or_filtering_is_set_clause))
                      .yield_self(&method(:hide_read_clause)) # checks whether "read/unread" toggle has been switched
                      .order(newest_first_order)
                      .paginate(page: params[:page], per_page: 7)
  end

  #(temporary?) feature requested by Joel & Allison.
  # used for training people to know about usual replies
  def joels_responses
    authorize EntryReply

    @entry_replies = EntryReply
                       .where(user: User.joel_beasley)
                       .order(created_at: :desc)
                       .paginate(page: params[:page], per_page: 7)
  end

  def show
    #NOTE: we're consciously ignoring complicated where condition here. It is all checked in pundit policy anyway
    @entry_group = EntryGroup
                     .where(id: params[:id])
                     .includes(:leaderbit, entries: [:user, replies: :user], user: %i[organization schedule])
                     .first!

    UserSeenEntryGroup.find_or_create_by! user: current_user, entry_group: @entry_group

    authorize @entry_group

    respond_to do |format|
      format.html
    end
  end

  def mark_as_read
    @entry_group = EntryGroup.find(params[:id])

    #:show? instead of :mark_as_read? policy fixes use case when user opens entry in a few tabs and hit mark as read in both
    # there were dozens of cases like this
    authorize @entry_group, :show?

    UserSeenEntryGroup.find_or_create_by! user: current_user, entry_group: @entry_group

    respond_to do |format|
      format.js
    end
  end

  private

  def hide_read_clause(relation)
    if params[:hide_read] == 'true'
      relation.unseen_by_user(current_user)
    else
      relation
    end
  end
end

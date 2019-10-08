# frozen_string_literal: true

class EntryRepliesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[create update destroy toggle_like]

  include ActionView::RecordIdentifier # dom_id

  def create
    entry = Entry.find params.dig(:entry_reply, :entry_id)
    authorize entry, :reply_to?

    entry_reply = EntryReply.create! content: params.dig(:entry_reply, :content),
                                     entry_id: entry.id,
                                     user_id: current_user.id,
                                     parent_reply_id: params.dig(:entry_reply, :parent_reply_id)

    render json: entry_reply.to_builder(current_user: current_user, entry: entry).attributes!.symbolize_keys!
  end

  def update
    entry_reply = EntryReply.find(params[:id])

    authorize entry_reply

    entry_reply.content = params.dig(:entry_reply, :content)
    entry_reply.save!

    render json: entry_reply.reload.to_builder(current_user: current_user, entry: entry_reply.entry).attributes!.symbolize_keys!
  end

  def destroy
    entry_reply = EntryReply.find params[:id]
    authorize entry_reply

    entry_reply.destroy!

    head :ok
  end

  def toggle_like
    entry_reply = EntryReply.find params.fetch(:id)

    authorize entry_reply.entry

    if current_user.favorited?(entry_reply)
      entry_reply.unliked_by current_user
      # @svg_class = 'disliked'
    else
      entry_reply.liked_by current_user
      # @svg_class = 'liked'
    end

    UserSeenEntryGroup.find_or_create_by! user: current_user, entry_group: entry_reply.entry.entry_group

    respond_to do |format|
      format.js { head :ok }

      format.html do
        redirect_to entry_group_url(entry_reply.entry.entry_group.to_param, anchor: dom_id(entry_reply))
      end
    end
  end
end

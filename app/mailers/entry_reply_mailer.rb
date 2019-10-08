# frozen_string_literal: true

class EntryReplyMailer < ApplicationMailer
  add_template_helper MailerHelper
  add_template_helper ApplicationHelper
  include ActionView::RecordIdentifier # dom_id

  #layout 'mailer_minimalist'
  layout 'mailer'

  def new_reply
    @entry_reply = params.fetch(:entry_reply)
    @email_recipient_user = params.fetch(:email_recipient_user)
    subject = params.fetch(:subject)

    @entry = @entry_reply.entry
    @leaderbit = @entry.leaderbit

    # could be nil
    @parent_entry_reply = @entry_reply.parent_entry_reply

    @user_token = @email_recipient_user.authentication_token

    # NOTE: keep in mind that old emails that we sent contained
    # entry_group_url(@entry.entry_group.to_param* links instead and they have to stay accessible
    @reply_action_url = entry_group_url(@entry.entry_group.to_param, user_email: @email_recipient_user.email, user_token: @user_token, anchor: dom_id(@entry_reply))

    mail(to: @email_recipient_user.as_email_to, subject: subject)
  end
end

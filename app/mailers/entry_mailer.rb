# frozen_string_literal: true

class EntryMailer < ApplicationMailer
  add_template_helper ApplicationHelper
  include ActionView::RecordIdentifier # dom_id

  #layout 'mailer_minimalist'
  layout 'mailer'

  # this mailer action was added in mid Apr 2019 as a way to notify
  # mentors(leaderits_sending_enabled=false) and team leaders about entries from their people
  # this was needed as a workaround to send 1st email to those recipients with auto-sign in Magic links
  # otherwise they will not be able to sign in because they don't receive LeaderBit emails.
  def first_entry_for_non_active_leaderbits_recipient_user_to_review
    @entry = params.fetch(:entry)
    @recipient_user = params.fetch(:recipient_user)

    mail(to: @recipient_user.as_email_to, subject: "New entry for you to review")
  end
end

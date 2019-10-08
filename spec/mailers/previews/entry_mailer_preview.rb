# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/leaderbit_mailer
class EntryMailerPreview < ActionMailer::Preview
  def first_entry_for_non_active_leaderbits_recipient_user_to_review
    EntryMailer
      .with(entry: Entry.all.sample, recipient_user: User.all.sample)
      .send(__method__)
  end
end

# frozen_string_literal: true

# note this service runs at end of day in EST time zone, called by Heroku via Scheduler rake task
class CheckIfActiveRecipientHasAnyKindOfLeaderbitToReceive
  def self.call
    users_without_leaderbits = User
                                 .active_recipient
                                 .reject { |u| u.next_leaderbit_to_send.present? }
                                 .reject { |u| u.unfinished_leaderbits_we_havent_notified_about.present? }

    return if users_without_leaderbits.blank?

    AdminMailer
      .with(users: users_without_leaderbits)
      .active_recipients_with_missing_upcoming_leaderbit
      .deliver_now
  end
end

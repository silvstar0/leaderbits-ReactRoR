# frozen_string_literal: true

# The point of this simple job is to contain single unit of work that has to be done asynchronously and could be restarted
class ScheduledNewLeaderbitMailerJob < ApplicationJob
  queue_as :default

  # @param [Integer] user_id
  # @param [Integer] leaderbit_id
  def perform(user_id, leaderbit_id)
    user = User.find user_id
    leaderbit = Leaderbit.find leaderbit_id

    begin
      LeaderbitMailer
        .with(
          user: user,
          leaderbit: leaderbit
        )
        .new_leaderbit
        .deliver_now

      # NOTE: it is important to create UserSentScheduledLeaderbit *after* mailer sending
      # otherwise user will receive wrong kind of notification(New Leaderbit Challenge instead of Welcome to LeaderBits.io)
      #TODO why there is this manual created_at setting. Is it still relevant?
      UserSentScheduledNewLeaderbit.create! user: user,
                                            resource: leaderbit,
                                            created_at: 1.second.ago

      SaveHistoricMomentumValues.call_for_user user
    # NOTE: logically it should be Postmark::InactiveRecipientError exception instead but that is how Postmark gem parses it in reality:
    rescue Postmark::InvalidMessageError => e
      email_regexp = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
      emails = e.message.scan(email_regexp).uniq
      emails.each do |email|
        be = BouncedEmail.find_or_initialize_by(email: email)

        # e.message
        # "You tried to send to a recipient that has been marked as inactive.\nFound inactive addresses: not@valid.address.\nInactive recipients are ones that have generated a
        be.message = if be.message.present?
                       be.message.to_s + "\n-----------------\n" + e.message
                     else
                       e.message
                     end
        be.save!
      end
      Rollbar.info(e)
    end
  end
end

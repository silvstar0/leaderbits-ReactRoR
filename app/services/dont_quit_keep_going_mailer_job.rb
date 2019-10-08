# frozen_string_literal: true

class DontQuitKeepGoingMailerJob
  include HasLatelyInactiveLeaders

  def self.call
    recently_inactive_leader_users
      .where('users.id NOT IN(SELECT user_id FROM user_sent_emails WHERE type = ? AND created_at > ?)', UserSentDontQuit.to_s, 14.days.ago)
      .each do |user|
      # too old and most likely inactive user. As of Dec 2018, this applies mostly to Cradlepoint, Adext and bimobject organization users
      next if user.next_leaderbit_to_send.blank?

      #as of Dec 2018 those all are early adopters. Currently mostly inactive
      next if user.missed_weeks_quantity >= 10

      if user.missed_weeks_quantity < 2
        Rollbar.scoped(user: user.inspect, missed_weeks_quantity: user.missed_weeks_quantity) do
          Rollbar.warning("Strange missed_weeks_quantity")
        end
        next
      end

      #NOTE: in future version you may need to stop sending emails if user stopped responding after N(2?) emails
      Rails.logger.info "user_id=#{user.id} sending dont quit to #{user.email}"

      AccountabilityMailer
        .with(user: user)
        .dont_quit
        .deliver_later

      user.user_sent_dont_quits.create!
    end
    nil
  end
end

# frozen_string_literal: true

require_dependency Rails.root.join('app/services/concerns/has_users_to_send_leaderbits_to')

# Why do we need leaderit sending plan/actual, LeaderbitSendingAnomalyDetection and extensive testing in HourlySendingOfLeaderbitEmails service?
# because that's the very core business feature of LeaderBits and because Joel requested it
# NOTE : this service class has to be fast and as stable as possible. Invalid email shouldn't break it for other users.
class HourlySendingOfLeaderbitEmails
  include HasUsersToSendLeaderbitsTo

  def self.call
    #TODO you may abstract User.active_recipient here and in HourlyLeaderbitSendingSummaryLog

    #originally this was used for making sure that leaderbits are not sent more often than once a week(even if same job runs multiple times)
    # so instead of 7 days we decreased it because of introduction of new "instant/manual sending feature" it might be needed in case like this:
    # we've just imported new organization and a few days later they contacted us with request to fix incorrect email and restart queue for him
    #   so you update email,
    #   click "Send Instantly" and 1st leaderbit will be sent right away and next leaderbit will be still sent on time(and not skipped)
    t1 = 3.days.ago
    User
      .active_recipient
      .where('users.id NOT IN(SELECT user_id FROM user_sent_emails WHERE type = ? AND created_at > ?)', UserSentScheduledNewLeaderbit.to_s, t1)
      .each do |user|
      unless send_during_this_hour?(user)
        debug_day = "#{time_now_in_user_tz(user).strftime('%A')}(#{user.day_of_week_to_send})"
        debug_hour = "#{time_now_in_user_tz(user).hour} (#{user.hour_of_day_to_send})"

        Rails.logger.info %(user_id=#{user.id} Skipping for #{user.email}. #{debug_day} #{debug_hour})
        next
      end

      #TODO rename it to "next_unseen/new_leaderbit_* ?"
      leaderbit = user.next_leaderbit_to_send
      if leaderbit.present?
        Rails.logger.info "user_id=#{user.id} Scheduling sending of *#{leaderbit.name}* leaderbit to *#{user.email}"

        ScheduledNewLeaderbitMailerJob.perform_later(user.id, leaderbit.id)
        next
      end

      # because order here is not important
      leaderbit = user.unfinished_leaderbits_we_havent_notified_about.sample
      if leaderbit.present?
        Rails.logger.info "user_id=#{user.id} Reminding *#{user.email} about unfinished leaderbit *#{leaderbit.name}*"

        IncompleteLeaderbitReminderMailerJob.perform_later(user.id, leaderbit.id)
        next
      end

      # it is important to touch user because otherwise intercom_custom_data
      # would still contain outdated data(e.g. Next Leaderbit To Send)
      user.touch

      message = "we run out of leaderbits to send for specific user"
      scope = {
        email: user.email,
        user_id: user.id
      }
      Rollbar.scoped(scope) { Rollbar.warning message }
      slack_notify "#{message} \n #{JSON.pretty_generate scope}"
    end
  end
end

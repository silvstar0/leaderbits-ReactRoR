# frozen_string_literal: true

require_dependency Rails.root.join('app/services/concerns/has_users_to_send_leaderbits_to')

# Why do we need leaderit sending plan/actual, LeaderbitSendingAnomalyDetection and extensive testing in HourlySendingOfLeaderbitEmails service?
# because that's the very core business feature of LeaderBits and because Joel requested it
# NOTE: this service class is executed every 10-minutes as part of Heroku Scheduler task
class LeaderbitSendingAnomalyDetection
  include HasUsersToSendLeaderbitsTo

  def self.call
    return unless call_now?

    #exclude_mentees_who_just_got_accepted_an_invitation
    exclude_user_ids = User.where('id IN(SELECT mentee_user_id FROM organizational_mentorships WHERE accepted_at > ?)', 2.hours.ago).pluck(:id)
    exclude_user_ids = [-1] if exclude_user_ids.blank?

    active_recipient_users = User
                               .active_recipient
                               .where.not(id: exclude_user_ids)


    expected_count = active_recipient_users.inject(0) do |count, user|
      send_during_this_hour?(user) ? count + 1 : count
    end

    expected_emails = active_recipient_users.select { |u| send_during_this_hour?(u) }.collect(&:email)

    t1 = Time.now.beginning_of_hour
    actual = UserSentEmail
               .where(type: [UserSentIncompleteLeaderbitReminder.to_s, UserSentScheduledNewLeaderbit.to_s])
               .preload(:user)
               .where('created_at > ? AND created_at < ?', t1, 1.hour.since(t1))
               .where('user_id NOT IN(?)', exclude_user_ids)

    actual_count = actual.count
    actual_emails = actual.collect(&:user).collect(&:email)

    if expected_count == actual_count
      return
    else
      #both way difference
      diff_emails = actual_emails - expected_emails | expected_emails - actual_emails
      scope = { expected: expected_count,
                actual: actual_count,
                expected_emails: expected_emails,
                actual_emails: actual_emails,
                diff_emails: diff_emails }
      message = if actual_count > expected_count
                  "Actual number of leaderbits to be sent is greater than planned"
                else
                  "Actual number of leaderbits to be sent is less than planned"
                end
      Rollbar.scoped(scope) { Rollbar.warning message }
      slack_notify "#{message} \n #{JSON.pretty_generate scope}"
    end
  end

  # NOTE: why 30-40?
  # sending usually starts at 2-nd minute, so we give it some time to finish.
  # And then some more in case we need to send smth manually as well. But not more than 30 mins total
  def self.call_now?
    (30..40).cover? Time.now.min
  end
end

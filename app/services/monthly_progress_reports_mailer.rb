# frozen_string_literal: true

class MonthlyProgressReportsMailer
  def self.call
    User
      .active_recipient
      .with_missing_recent_monthly_progress_report
      .each do |user|
      #NOTE: make sure it is wrapper on per-user basis because for some users it may fail(out of leaderbits to send, no ongoing leaderbit)
      if user.user_sent_scheduled_new_leaderbits.blank?
        # rare case? New user, waiting for his 1st leaderbit and time of monthly progress report comes?
        raise "#{user.id} does not have any user_sent_scheduled_new_leaderbits can not send monthly progress report"
      end

      AccountabilityMailer
        .with(user: user)
        .monthly_progress_report
        .deliver_later

      UserSentMonthlyProgressReport.create! user: user
    rescue StandardError => e
      Rails.logger.warn "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
      Rollbar.scoped(user: user.inspect) do
        Rollbar.error(e)
      end
    end
  end
end

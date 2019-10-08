# frozen_string_literal: true

class UserIsSlackingOffMailerJob
  include HasLatelyInactiveLeaders

  def self.call
    recently_inactive_leader_users
      .where.not(notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks: nil)
      .each do |user|
      # too old and most likely inactive user
      # could happen in case "Slacking off" reminder has been disabled for rather old user
      next if user.next_leaderbit_to_send.blank?

      #TODO check on per user/progress report recipient level

      #puts user.missed_weeks_quantity if ENV['DEBUG']

      next unless user.missed_weeks_quantity == 3

      progress_report_recipient = ProgressReportRecipient.includes(:user).where(id: user.notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks).first!

      leader_user_ids = progress_report_recipient
                          .user
                          .user_sent_leader_is_slacking_offs
                          .pluck(:params)
                          .collect { |params| params.symbolize_keys.fetch(:leader_user_id) }
      next if leader_user_ids.include?(user.id)

      #TODO check if recipient is still a valid user and not soft deleted?

      begin
        AccountabilityMailer
          .with(progress_report_recipient: progress_report_recipient, user: user)
          .user_is_slacking_off
          .deliver_now

        progress_report_recipient.user.user_sent_leader_is_slacking_offs.create!(params: { leader_user_id: user.id })
      rescue StandardError => e
        Rollbar.scoped(user_id: user.id, progress_report_recipient_id: progress_report_recipient.id) do
          Rollbar.error(e)
        end
        Rails.logger.warn("Failed to UserIsSlackingOffMailerJob: #{e.message}\n#{e.backtrace.join("\n")}")
        raise(e) if Rails.env.development? || Rails.env.test?
      end
    end
  end
end

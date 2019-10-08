# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/leaderbit_mailer
class AccountabilityMailerPreview < ActionMailer::Preview
  def user_is_progressing_as_leader
    skip_bullet do
      leaderbit_log = LeaderbitLog
                        .completed
                        .includes(:leaderbit)
                        .where(updated_at: 4.weeks.ago..Time.now)
                        .select do |leaderbit_log|
        Entry.where(leaderbit: leaderbit_log.leaderbit, user: leaderbit_log.user).exists?
      end.sample || raise

      user = leaderbit_log.user
      recipient_user = User.where.not(id: user.id).sample || raise("missing recipient_user in #{__method__}")

      leaderbit_logs = LeaderbitLog
                         .completed
                         .includes(:leaderbit)
                         .where(updated_at: 4.weeks.ago..Time.now)
                         .where(user_id: user.id)
                         .order(updated_at: :desc)

      AccountabilityMailer
        .with(user: user, leaderbit_logs: leaderbit_logs, recipient_user: recipient_user)
        .send(__method__)
    end
  end

  def monthly_progress_report_non_blank
    skip_bullet do
      leaderbit_log = LeaderbitLog
                        .completed
                        .where(updated_at: 4.weeks.ago..Time.now)
                        .includes(:leaderbit)
                        .select do |leaderbit_log|
        Entry.where(leaderbit: leaderbit_log.leaderbit, user: leaderbit_log.user).exists?
      end.sample || raise("missing leaderbit log in #{__method__}")

      user = leaderbit_log.user

      AccountabilityMailer
        .with(user: user)
        .monthly_progress_report
    end
  end

  #TODO think about when out of leaderbits to send, no ongoing leaderbit
  def monthly_progress_report_blank_has_inprogress_leaderbit
    skip_bullet do
      user = User
               .where('id IN(SELECT user_id FROM leaderbit_logs WHERE status = ?)', LeaderbitLog::Statuses::IN_PROGRESS)
               .where('id NOT IN(SELECT user_id FROM leaderbit_logs WHERE status = ?)', LeaderbitLog::Statuses::COMPLETED)
               .all
               .sample || raise("missing user in #{__method__}")

      AccountabilityMailer
        .with(user: user)
        .monthly_progress_report
    end
  end

  def monthly_progress_report_blank_no_inprogress_leaderbit
    skip_bullet do
      user = User
               .where('id NOT IN(SELECT user_id FROM leaderbit_logs)')
               .where('id IN(SELECT user_id FROM user_sent_emails WHERE type = ?)', UserSentScheduledNewLeaderbit.to_s)
               .all
               .sample || raise("missing user in #{__method__}")

      AccountabilityMailer
        .with(user: user)
        .monthly_progress_report
    end
  end

  def dont_quit
    user = User.all.select { |u| u.missed_weeks_quantity > 0 }.sample || raise

    AccountabilityMailer
      .with(user: user)
      .send(__method__)
  end

  def user_is_trying_to_hide
    skip_bullet do
      user = User.all.sample || raise

      AccountabilityMailer
        .with(user: user, recipient_name: Faker::Name.name, recipient_email: Faker::Internet.email)
        .send(__method__)
    end
  end

  def user_is_slacking_off
    skip_bullet do
      user = User.all.sample || raise
      progress_report_recipient = ProgressReportRecipient.all.sample || raise

      AccountabilityMailer
        .with(user: user, progress_report_recipient: progress_report_recipient)
        .send(__method__)
    end
  end
end

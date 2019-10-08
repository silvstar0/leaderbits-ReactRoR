# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview
  def notify_joel_about_new_inactive_leaderbit
    skip_bullet do
      leaderbit = Leaderbit.all.sample || raise("Missing leaderbit in #{__method__}")
      created_by = User.all.sample || raise("Missing leaderbit in #{__method__}")

      AdminMailer.with(leaderbit: leaderbit, created_by: created_by).send(__method__)
    end
  end

  def user_lifetime_progress_dump
    skip_bullet do
      leaderbit_log = LeaderbitLog
                        .completed
                        .includes(:leaderbit)
                        .select do |leaderbit_log|
        Entry.where(leaderbit: leaderbit_log.leaderbit, user: leaderbit_log.user).exists?
      end.sample || raise

      user = leaderbit_log.user

      AdminMailer
        .with(user: user)
        .send(__method__)
    end
  end

  def active_recipients_with_missing_upcoming_leaderbit
    scope = User.where.not(schedule: nil)
    users = [[scope.sample], scope.shuffle.take(4)].sample

    raise unless users.size.positive?

    AdminMailer
      .with(users: users)
      .send(__method__)
  end

  def active_recipients_with_missing_leaderbit_employee_mentor
    scope = User.where.not(schedule: nil)
    users = [[scope.sample], scope.shuffle.take(4)].sample

    raise unless users.size.positive?

    AdminMailer
      .with(users: users)
      .send(__method__)
  end

  def organization_lifetime_progress_dump
    skip_bullet do
      leaderbit_log = LeaderbitLog
                        .completed
                        .includes(:leaderbit)
                        .select do |leaderbit_log|
        Entry.where(leaderbit: leaderbit_log.leaderbit, user: leaderbit_log.user).exists?
      end.sample || raise

      user = leaderbit_log.user

      AdminMailer
        .with(organization: user.organization, recipient_email: Faker::Internet.email)
        .send(__method__)
    end
  end
end

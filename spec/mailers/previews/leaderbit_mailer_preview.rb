# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/leaderbit_mailer
class LeaderbitMailerPreview < ActionMailer::Preview
  def new_leaderbit_for_first_leaderbit
    skip_bullet do
      organization1 = Organization
                        .present_first_leaderbit_introduction_message
                        .sample || raise("Missing organization with present first_leaderbit_introduction_message")

      organization2 = Organization
                        .missing_first_leaderbit_introduction_message
                        .sample || raise("Missing organization with blank first_leaderbit_introduction_message")

      user1 = organization1
                .users
                .where.not(schedule_id: nil)
                .select { |u| u.received_uniq_leaderbit_ids.blank? }
                .sample || OpenStruct.new(as_email_to: Faker::Internet.email, organization: organization1, received_uniq_leaderbit_ids: [])

      user2 = organization2
                .users
                .where.not(schedule_id: nil)
                .select { |u| u.received_uniq_leaderbit_ids.blank? }
                .sample || OpenStruct.new(as_email_to: Faker::Internet.email, organization: organization2, received_uniq_leaderbit_ids: [])

      leaderbit = Leaderbit.all.sample || raise("Missing leaderbit in #{__method__}")

      LeaderbitMailer.with(user: [user1, user2].sample, leaderbit: leaderbit).new_leaderbit
    end
  end

  def new_leaderbit_for_consequent_leaderbits
    skip_bullet do
      user = users.shuffle.detect do |user|
        LeaderbitLog.where(user: user).exists?
      end || raise("Missing user in #{__method__}")

      started_ids = LeaderbitLog.where(user: user).pluck(:leaderbit_id)
      leaderbit = Leaderbit
                    .where(id: started_ids)
                    .sample || raise("Missing leaderbit in #{__method__}")

      LeaderbitMailer.with(user: user, leaderbit: leaderbit).new_leaderbit
    end
  end

  def uncompleted_leaderbit_reminder
    skip_bullet do
      user = User.all.sample
      leaderbit = Leaderbit.all.sample

      LeaderbitMailer.with(user: user, leaderbit: leaderbit).send(__method__)
    end
  end

  def boomerang_single_leaderbit_entry
    skip_bullet do
      leaderbits_entries = ActiveRecord::Base.connection.execute("SELECT leaderbit_id, user_id FROM entries GROUP BY 1, 2 HAVING COUNT(*) = 1").values

      leaderbit_id, user_id = leaderbits_entries.sample

      LeaderbitMailer
        .with(leaderbit: Leaderbit.find(leaderbit_id), user: User.find(user_id))
        .boomerang
    end
  end

  def boomerang_multiple_leaderbit_entries
    skip_bullet do
      leaderbits_entries = ActiveRecord::Base.connection.execute("SELECT leaderbit_id, user_id FROM entries GROUP BY 1, 2 HAVING COUNT(*) > 1").values

      leaderbit_id, user_id = leaderbits_entries.sample

      LeaderbitMailer
        .with(leaderbit: Leaderbit.find(leaderbit_id), user: User.find(user_id))
        .boomerang
    end
  end

  private

  def users
    User
      .where.not(schedule_id: nil)
      .where(discarded_at: nil)
      .joins(:organization)
  end
end

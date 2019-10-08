# frozen_string_literal: true

class SendWeeklyTeamReports
  def self.call
    Team
      .joins(:organization)
      .where('organizations.active_since < ?', Time.zone.now)
      .where('organizations.leaderbits_sending_enabled IS TRUE')
      .each do |team|
      #NOTE: it is important to fetch users in spite of their leaderbits_sending_enabled status
      # because there could be a team leader who's there just for watching and replying to entries.
      # Such user still need to receive this report
      users = User
                .where(id: team.users.collect(&:id))
                .where('users.discarded_at IS NULL')
                .where('users.schedule_id IS NOT NULL')

      #TODO do we really need that check?
      next if users.size < 2

      users.each do |user|
        if user.created_at > 1.week.ago
          puts "Skipping weekly report for #{user.email} because user is new" if Rails.env.staging? || Rails.env.production?
          next
        end

        UserMailer
          .with(team: team, user: user)
          .weekly_team_progress_report
          .yield_self { |mail_message| Rails.env.development? || Rails.env.test? ? mail_message.deliver_now : mail_message.deliver_later }

        UserSentWeeklyTeamProgressReport.create!(user: user, team: team)
      rescue StandardError => e
        puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
        Rails.logger.error e

        Rollbar.scoped(team_id: team.id, user_id: user.id) do
          Rollbar.error(e)
        end
      end
    end
  end
end

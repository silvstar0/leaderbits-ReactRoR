# frozen_string_literal: true

class UserIsProgressingAsLeaderMailerJob
  def self.call
    progress_report_recipients = ProgressReportRecipient
                                   .where(added_by_user_id: User.active_recipient.pluck(:id))
                                   .includes(:added_by_user, :user)

    progress_report_recipients.each do |progress_report_recipient|
      added_by_user = progress_report_recipient.added_by_user
      user = progress_report_recipient.user

      # Checking 3 conditions here:
      # * if User is too fresh/young for such "rare" report
      # * if user had any completed leaderbits during this period NOTE: the goal of this job(and progress reports in general) is to send only *positive* updates(if there are any completed challenges) # other job handles it when user slacks off and not progressing
      # * if user already received this report recently

      base_leaderbit_logs_scope = added_by_user
                                    .leaderbit_logs
                                    .completed
                                    .includes(:leaderbit)
                                    .order(updated_at: :desc)
      if progress_report_recipient.weekly?
        next if added_by_user.created_at > 1.week.ago

        leaderbit_logs = base_leaderbit_logs_scope.where(updated_at: 1.week.ago..Time.zone.now)
        next if leaderbit_logs.blank?

        next if user.user_sent_user_is_progressing_as_leaders.where(resource: added_by_user, created_at: 1.week.ago..Time.zone.now).exists?
      elsif progress_report_recipient.bi_monthly?
        next if added_by_user.created_at > 2.weeks.ago

        leaderbit_logs = base_leaderbit_logs_scope.where(updated_at: 2.weeks.ago..Time.zone.now)
        next if leaderbit_logs.blank?

        next if user.user_sent_user_is_progressing_as_leaders.where(resource: added_by_user, created_at: 2.weeks.ago..Time.zone.now).exists?
      elsif progress_report_recipient.monthly?
        next if added_by_user.created_at > 4.weeks.ago

        leaderbit_logs = base_leaderbit_logs_scope.where(updated_at: 4.weeks.ago..Time.zone.now)
        next if leaderbit_logs.blank?

        next if user.user_sent_user_is_progressing_as_leaders.where(resource: added_by_user, created_at: 4.weeks.ago..Time.zone.now).exists?
      else
        raise progress_report_recipient.frequency.inspect
      end

      #NOTE: it is important to rescue on per-user level to prevent single exception from canceling the whole queue
      begin
        # NOTE: it is purposely not #deliver_later because
        # leaderbit_logs is a collection and ActiveJob doesn't seem to like collection params:
        # >Could not execute command [ActiveJob::SerializationError - Unsupported argument type: ActiveRecord::AssociationRelation]: /home/nikita/.asdf/installs/ruby/2.6.2/lib/ruby/gems/2.6.0/gems/activejob-5.2.2.1/lib/active_job/arguments.rb:73:in `serialize_argument' | /home/nikita/.asdf/installs/ruby/2.6.2/lib/ruby/gems/2.6.0/gems/activejob-5.2.2.1/lib/active_job/arguments.rb:106:in `block in serialize_hash' | /home/nikita/.asdf/installs/ruby/2.6.2/lib/ruby/gems/2.6.0/gems/activejob-5.2.2.1/lib/active_job/arguments.rb:105:in `each' | /home/nikita/.asdf/installs/ruby/2.6.2/lib/ruby/gems/2.6.0/gems/activejob-5.2.2.1/lib/active_job/arguments.rb:105:in `each_with_object' | /home/nikita/.asdf/installs/ruby/2.6.2/lib/ruby/gems/2.6.0/gems/activejob-5.2.2.1/lib/active_job/arguments.rb:105:in `serialize_hash'
        # Do NOT move leaderbit_logs fetching inside #user_is_progressing_as_leader - it was like that and it was not fun. See the referenced commits for mor info
        AccountabilityMailer
          .with(
            user: added_by_user,
            leaderbit_logs: leaderbit_logs,
            recipient_user: user
          )
          .user_is_progressing_as_leader
          .deliver_now

        user.user_sent_user_is_progressing_as_leaders.create! resource: added_by_user
      rescue StandardError => e
        puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"

        Rollbar.scoped(progress_report_recipient: progress_report_recipient.inspect) do
          Rollbar.error(e)
        end
      end
    end
  end
end

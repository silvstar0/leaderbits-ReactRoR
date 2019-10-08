# frozen_string_literal: true

#:nocov:
desc "Send out leaderbits"
task send_new_leaderbits_email: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"
  HourlySendingOfLeaderbitEmails.call
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end

desc "Leaderbits sending plan/actual sent logging"
task hourly_leaderbit_sending_summary_log: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  HourlyLeaderbitSendingSummaryLog.call
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end

# NOTE: why hourly rake instead of Sidekiq with enqueue_in?
# because boomerang send time/options are too prone for change
# and it's much easier to just change rake task than replacing it in sidekiq queue.
desc "Send boomerang"
task send_boomerang: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  HourlySendingOfBoomerang.call
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end
#:nocov:

desc "Heroku Scheduler hour job task"
task hour_scheduler_task: %i[send_new_leaderbits_email hourly_leaderbit_sending_summary_log send_boomerang] do |rake_task|
  rake_puts "#{rake_task.name} has been called"
end

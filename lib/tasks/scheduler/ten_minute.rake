# frozen_string_literal: true

#:nocov:
desc "Leaderbits sending anomaly detection"
task leaderbits_sending_anomaly_detection: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  LeaderbitSendingAnomalyDetection.call
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end
#:nocov:

desc "Heroku Scheduler 10min job task"
task ten_minute_scheduler_task: %i[leaderbits_sending_anomaly_detection] do |rake_task|
  rake_puts "#{rake_task.name} has been called"
end

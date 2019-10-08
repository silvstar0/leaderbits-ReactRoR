# frozen_string_literal: true

#:nocov:

desc "Save historic user momentum values"
task save_historic_momentum_values: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  SaveHistoricMomentumValues.call_for_all
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end

desc "Email-notify invited mentees about pending inviations"
task remind_about_pending_mentee_invitations: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  NotifyMenteesAboutPendingInvitations.call
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end


#NOTE: you don't need to check to make sure it runs exactly once a month.
# All checking logic is done within actual service on per user basis
desc "Monthly progress reports mailer"
task monthly_progress_reports_mailer: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  MonthlyProgressReportsMailer.call
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end

desc "Don't quit. Keep going mailer notification"
task dont_quit_keep_going_mailer: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  DontQuitKeepGoingMailerJob.call
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end

desc "User is slacking off mailer notification"
task user_is_slacking_off_mailer: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  UserIsSlackingOffMailerJob.call
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end

desc "User is progressing as leader mailer notification"
task user_is_progressing_as_leader_mailer: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  UserIsProgressingAsLeaderMailerJob.call
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end

desc "Check if now is Sunday and you need to trigger week_scheduler_task"
task check_if_need_to_trigger_weekly_task: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  SendWeeklyTeamReports.call if Time.now.sunday?
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end

desc "Extract details on IP addresses"
task extract_details_on_ip_addresses: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  ExtractDetailsOnIpAddresses.call
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end

desc "Check if active recipients have upcoming leaderbit to receive"
task check_if_active_recipients_have_upcoming_leaderbit: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  CheckIfActiveRecipientHasAnyKindOfLeaderbitToReceive.call
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end

desc "Check if active recipients have an assigned employee-mentor"
task check_if_active_recipients_have_employee_mentor: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  CheckIfAllUsersHaveLeaderbitEmployeeMentors.call
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end

desc "Check if all users have leaderbit employee mentors"
task check_if_all_users_have_leaderbit_employee_mentors: :environment do |rake_task|
  rake_puts "#{rake_task.name} has been called"

  CheckIfActiveRecipientHasAnyKindOfLeaderbitToReceive.call
rescue StandardError => e
  rake_puts "Could not execute command [#{e.class} - #{e.message}]: #{e.backtrace.first(5).join(' | ')}"
  Rollbar.error(e)
end
#:nocov:

day_scheduler_sub_tasks = %i[
  save_historic_momentum_values
  remind_about_pending_mentee_invitations
  dont_quit_keep_going_mailer
  user_is_progressing_as_leader_mailer
  monthly_progress_reports_mailer
  user_is_slacking_off_mailer
  check_if_need_to_trigger_weekly_task
  check_if_active_recipients_have_upcoming_leaderbit
  check_if_active_recipients_have_employee_mentor
  check_if_all_users_have_leaderbit_employee_mentors
  extract_details_on_ip_addresses
]
# Currently Heroku runs it at 10PM EST time
desc "Heroku Scheduler daily job task"
task day_scheduler_task: day_scheduler_sub_tasks do |rake_task|
  rake_puts "#{rake_task.name} has been called"
end

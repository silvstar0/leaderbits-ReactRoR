# frozen_string_literal: true

# note this service runs at end of day in EST time zone, called by Heroku via Scheduler rake task
class CheckIfAllUsersHaveLeaderbitEmployeeMentors
  def self.call
    users_without_leaderit_employee_mentor = User
                                               .active_recipient
                                               .where('users.id NOT IN(SELECT mentee_user_id FROM leaderbit_employee_mentorships)')
    return if users_without_leaderit_employee_mentor.blank?

    AdminMailer
      .with(users: users_without_leaderit_employee_mentor)
      .active_recipients_with_missing_leaderbit_employee_mentor
      .deliver_now
  end
end

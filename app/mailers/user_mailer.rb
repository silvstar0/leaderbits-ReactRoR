# frozen_string_literal: true

class UserMailer < ApplicationMailer
  add_template_helper ApplicationHelper
  add_template_helper MailerHelper
  add_template_helper PointSystemHelper

  def weekly_team_progress_report
    @user = params.fetch(:user)
    @team = params.fetch(:team)

    @t1 = Time.zone.now.beginning_of_week
    @t2 = Time.zone.now.end_of_week

    #NOTE it is important to only display users with leaderbits_sending_enabled=true status
    # otherwise such spectator/mentor/inactive users would hurt overall team stats
    @active_recipient_team_users = User
                                     .where(id: @team.users.collect(&:id))
                                     .where('users.discarded_at IS NULL')
                                     .where('users.leaderbits_sending_enabled IS TRUE')
                                     .where('users.schedule_id IS NOT NULL')

    raise("can not find users in team - #{@team.id}") if @active_recipient_team_users.blank?

    points_scope = Point.where(user: @active_recipient_team_users)
    @this_week_team_points = points_scope
                               .where(created_at: @t1..@t2)

    past_week_team_points = points_scope
                              .where(created_at: 1.week.until(@t1)..1.week.until(@t2))

    @points_explanation = extract_points_explanation(past_week_team_points, points_scope)

    leaderbit_logs_scope = LeaderbitLog
                             .completed
                             .where(user: @active_recipient_team_users)
                             .includes(:leaderbit)
                             .order(updated_at: :desc)

    @this_week_completed_leaderbit_logs = leaderbit_logs_scope
                                            .where(updated_at: @t1..@t2)


    past_week_completed_leaderbit_logs = leaderbit_logs_scope
                                           .where(updated_at: 1.week.until(@t1)..1.week.until(@t2))

    @completed_challenges_explanation = extract_completed_challenges_explanation(leaderbit_logs_scope, past_week_completed_leaderbit_logs)

    momentums = @active_recipient_team_users.collect(&:momentum)
    @this_week_average_momentum = (momentums.reduce(:+) / momentums.size.to_f).round

    at_time = 1.week.ago
    momentums = @active_recipient_team_users.collect { |user| user.momentum_at_time(at_time) }
    past_week_average_momentum = (momentums.reduce(:+) / momentums.size.to_f).round

    @momentum_explanation = extract_momentum_explanation(past_week_average_momentum)

    #TODO-low include team name?
    mail(to: @user.as_email_to, subject: "Weekly summary")
  end

  def invitation_to_participate_anonymously_in_survey
    @anonymous_survey_participant = AnonymousSurveyParticipant.find params.fetch(:anonymous_survey_participant_id)

    #TODO-low rename @user? not explicit enough
    @user = @anonymous_survey_participant.added_by_user

    @survey = Survey.for_follower.where(anonymous_survey_participant_role: @anonymous_survey_participant.role).first!

    #TODO-low google docs include team member name as well
    #{teamMember.name} - {mentor.name} and I need your feedback.
    mail(to: @anonymous_survey_participant.email, subject: "#{@user.name} and I need your feedback")
  end

  def anonymous_survey_completed
    #TODO-low in case you need to provide some additional info you'll need to pass @survey param as well
    @user = params.fetch(:user)

    mail(to: @user.as_email_to, subject: "New survey response")
  end

  def invitation_to_become_mentee
    @organizational_mentorship = OrganizationalMentorship.find(params.fetch(:organizational_mentorship_id))

    @accept_mentee_invitation_url = accept_mentee_invitation_url

    mail(to: @organizational_mentorship.mentee_user.as_email_to, subject: "Mentor invitation from #{@organizational_mentorship.mentor_user.name}")
  end

  def reminder_about_pending_invitation_to_become_mentee
    @organizational_mentorship = OrganizationalMentorship.find(params.fetch(:organizational_mentorship_id))

    @accept_mentee_invitation_url = accept_mentee_invitation_url

    mail(to: @organizational_mentorship.mentee_user.as_email_to, subject: "Reminder: Mentor invitation from #{@organizational_mentorship.mentor_user.name}")
  end

  def mentee_accepted_invitation
    @organizational_mentorship = OrganizationalMentorship.find(params.fetch(:organizational_mentorship_id))

    mail(to: @organizational_mentorship.mentor_user.as_email_to, subject: "#{@organizational_mentorship.mentee_user.name} has accepted your invitation")
  end

  def your_magic_sign_in_link
    @user = params.fetch(:user)
    @url = params.fetch(:url)

    mail(to: @user.as_email_to, subject: "Magic Sign-in link is here")
  end

  private

  def extract_momentum_explanation(past_week_average_momentum)
    if @this_week_average_momentum == past_week_average_momentum
      "(same as previous week)"
    elsif @this_week_average_momentum < past_week_average_momentum
      "(that's #{past_week_average_momentum - @this_week_average_momentum}% fewer than the week before)"
    elsif @this_week_average_momentum > past_week_average_momentum
      "(that's #{@this_week_average_momentum - past_week_average_momentum}% more than the week before)"
    end
    #TODO-low add missing else raise ?
  end

  def extract_completed_challenges_explanation(leaderbit_logs_scope, past_week_completed_leaderbit_logs)
    if leaderbit_logs_scope.count == @this_week_completed_leaderbit_logs.count
      # first week, no need to compare it with previous one
    elsif @this_week_completed_leaderbit_logs.count == past_week_completed_leaderbit_logs.count
      "(same as previous week)"
    elsif @this_week_completed_leaderbit_logs.count < past_week_completed_leaderbit_logs.count
      "(that's #{past_week_completed_leaderbit_logs.count - @this_week_completed_leaderbit_logs.count} fewer than the week before)"
    elsif @this_week_completed_leaderbit_logs.count > past_week_completed_leaderbit_logs.count
      "(that's #{@this_week_completed_leaderbit_logs.count - past_week_completed_leaderbit_logs.count} more than the week before)"
    end
    #TODO-low add missing else raise ?
  end

  def extract_points_explanation(past_week_team_points, points_scope)
    if points_scope.count == @this_week_team_points.count
      # first week, no need to compare it with previous one
    elsif @this_week_team_points.count == past_week_team_points.count
      "(same as previous week)"
    elsif @this_week_team_points.count < past_week_team_points.count
      "(that's #{past_week_team_points.count - @this_week_team_points.count} fewer than the week before)"
    elsif @this_week_team_points.count > past_week_team_points.count
      "(that's #{@this_week_team_points.count - past_week_team_points.count} more than the week before)"
    end
    #TODO-low add missing else raise ?
  end

  #The reason why it has been extracted is to
  # * clearly show how&when it is reused
  # * make both actions covered by specs although we only have capybara spec covered one of them
  def accept_mentee_invitation_url
    accept_organizational_mentorship_url(id: @organizational_mentorship.id, user_email: @organizational_mentorship.mentee_user.email, user_token: @organizational_mentorship.mentee_user.issue_new_authentication_token_and_return)
  end
end

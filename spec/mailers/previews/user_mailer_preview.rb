# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def invitation_to_participate_anonymously_in_survey_when_direct_report_role
    #TODO-low exclude ids with were already surveyed
    UserMailer
      .with(anonymous_survey_participant_id: AnonymousSurveyParticipant.where(role: AnonymousSurveyParticipant::Roles::DIRECT_REPORT).all.sample.id)
      .invitation_to_participate_anonymously_in_survey
  end

  def invitation_to_participate_anonymously_in_survey_when_leader_or_mentor_role
    #TODO-low exclude ids with were already surveyed
    UserMailer
      .with(anonymous_survey_participant_id: AnonymousSurveyParticipant.where(role: AnonymousSurveyParticipant::Roles::LEADER_OR_MENTOR).all.sample.id)
      .invitation_to_participate_anonymously_in_survey
  end

  def invitation_to_participate_anonymously_in_survey_when_peer_role
    #TODO-low exclude ids with were already surveyed
    UserMailer
      .with(anonymous_survey_participant_id: AnonymousSurveyParticipant.where(role: AnonymousSurveyParticipant::Roles::PEER).all.sample.id)
      .invitation_to_participate_anonymously_in_survey
  end

  def anonymous_survey_completed
    user_ids = Answer.joins(:anonymous_survey_participant).pluck('anonymous_survey_participants.added_by_user_id').uniq

    UserMailer
      .with(user: User.find(user_ids.sample))
      .send(__method__)
  end

  def invitation_to_become_mentee
    UserMailer
      .with(organizational_mentorship_id: OrganizationalMentorship.all.sample.id)
      .send(__method__)
  end

  def reminder_about_pending_invitation_to_become_mentee
    UserMailer
      .with(organizational_mentorship_id: OrganizationalMentorship.all.sample.id)
      .send(__method__)
  end

  def mentee_accepted_invitation
    UserMailer
      .with(organizational_mentorship_id: OrganizationalMentorship.all.sample.id)
      .send(__method__)
  end

  def your_magic_sign_in_link
    UserMailer
      .with(user: User.all.sample, url: Faker::Internet.url)
      .send(__method__)
  end

  def weekly_team_progress_report
    # jeff and his team
    #team = Team.find 35
    #user = User.find 390
    teams = Team.all.select do |t|
      User
        .where(id: t.users.collect(&:id))
        .where('users.discarded_at IS NULL')
        .where('users.leaderbits_sending_enabled IS TRUE')
        .where('users.schedule_id IS NOT NULL')
        .exists?
    end
    team = teams.shuffle.sample

    UserMailer
      .with(user: team.users.sample, team: team)
      .send(__method__)
  end
  #TODO include other use cases - weekly team progress report have lots of use cases
end

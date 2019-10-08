# frozen_string_literal: true

class FindOrCreateNewOrganizationalMentorship
  #TODO rename method? to smth like find_or_create_and_return?
  # @return [OrganizationalMentorship] new user mentee instance that you may(or may not use) depending on use case
  # @param [Hash] options
  def self.create_and_return(options)
    email = options.fetch(:email)
    current_user = options.fetch(:current_user)
    name = options.fetch(:name) {}

    #without this pre-formatting it would fail when current_user types email with capital letter
    # and such email already exists in our db
    email = email.downcase

    user = fetch_or_create_user email, name, current_user

    #NOTE: you don't need to send leaderbit right away,
    # it is done only after invitation is accepted

    if user_mentee = OrganizationalMentorship.find_by(mentor_user: current_user, mentee_user: user)
      return user_mentee
    end

    OrganizationalMentorship
      .create!(mentor_user: current_user, mentee_user: user)
      .tap(&:mailer_notify)
  end

  # @return [User]
  def self.fetch_or_create_user(email, name, created_by_current_user)
    user = User.where(email: email).first
    return user if user.present?

    #NOTE: it is important to assign a schedule here because 1st leaderbit is sent right after invitation is accepted
    user = User.new(email: email,
                    name: name,
                    time_zone: created_by_current_user.time_zone,
                    organization: created_by_current_user.organization,
                    hour_of_day_to_send: created_by_current_user.organization.hour_of_day_to_send,
                    day_of_week_to_send: created_by_current_user.organization.day_of_week_to_send,

                    # this is needed for a proper sending anomaly detection. Excluding new invited users until they accept an invitation
                    leaderbits_sending_enabled: false,

                    created_by_user_id: created_by_current_user.id,

                    #right after welcome video mentee will start a challenge right away
                    goes_through_leader_welcome_video_onboarding_step: true,

                    goes_through_leader_strength_finder_onboarding_step: true,
                    goes_through_team_survey_360_onboarding_step: true,
                    goes_through_organizational_mentorship_onboarding_step: false,

                    #TODO Joel will create custom schedule for mentees
                    schedule_id: Schedule.find_by_name(Schedule::GLOBAL_NAME).id)

    def user.password_required?
      false
    end

    user.save!
    user
  end

  private_class_method :fetch_or_create_user
end

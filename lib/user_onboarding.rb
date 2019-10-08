# frozen_string_literal: true

class UserOnboarding
  def initialize(current_user)
    @current_user = current_user

    extract_steps
  end

  def next_step_after(step)
    unless User::OnboardingSteps::ALL.include?(step)
      raise ArgumentError, "cant interpret #{step} step. Available steps: #{User::OnboardingSteps::ALL.inspect}"
    end

    index = @ordered_steps.index(step)
    @ordered_steps[index + 1]
  end

  def first_step
    @ordered_steps.first
  end

  def last_step
    @ordered_steps.last
  end

  private

  def extract_steps
    @ordered_steps = []

    if @current_user.goes_through_leader_welcome_video_onboarding_step?
      @ordered_steps << User::OnboardingSteps::WELCOME_VIDEO_ONBOARDING_STEP
    end

    if @current_user.goes_through_leader_strength_finder_onboarding_step?
      @ordered_steps << User::OnboardingSteps::LEADER_STRENGTH_FINDER_ONBOARDING_STEP
    end

    if @current_user.goes_through_team_survey_360_onboarding_step?
      @ordered_steps << User::OnboardingSteps::TEAM_SURVEY_360_ONBOARDING_STEP
    end

    if @current_user.goes_through_organizational_mentorship_onboarding_step?
      @ordered_steps << User::OnboardingSteps::ORGANIZATIONAL_MENTORSHIP_ONBOARDING_OPTIONAL_STEP
    end
  end
end

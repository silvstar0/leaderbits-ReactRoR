# frozen_string_literal: true

module HomeHelper
  def multistep_onboarding_step_status
    welcome_video_step = 1

    max_steps = welcome_video_step \
      + (current_user.goes_through_leader_strength_finder_onboarding_step && 1 || 0) \
      + (current_user.goes_through_team_survey_360_onboarding_step && 1 || 0) \
      + (current_user.goes_through_organizational_mentorship_onboarding_step && 1 || 0)

    return '' if max_steps == 1

    queue = []
    queue << 'welcome_video'
    queue << 'leader_strength_finder' if current_user.goes_through_leader_strength_finder_onboarding_step?
    queue << 'team_survey_360' if current_user.goes_through_team_survey_360_onboarding_step?
    queue << 'mentorship' if current_user.goes_through_organizational_mentorship_onboarding_step?

    step = queue.index(action_name)
    raise "can not find #{action_name} in #{queue.inspect}" if step.nil?

    step += 1

    %(<font style="font-size: 18px;">STEP #{step} / #{max_steps}).html_safe
  end
end

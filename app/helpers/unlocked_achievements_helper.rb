# frozen_string_literal: true

module UnlockedAchievementsHelper
  def points_message
    "+#{pluralize current_user.points_for_latest_event, 'point'}"
  end

  # @return [String] e.g. "1st challenge completed"
  def challenge_name_completed_message
    "#{current_level_num(current_user).ordinalize} challenge completed"
  end

  def congrats_achievement_message
    #NOTE: know a better method for disabling partial turbograft update for this link? Feel free to update it.
    raw <<~HEREDOC
      <div>
        Congratulations!
        <br/>
        You've unlocked your dashboard.
        <br/>
        #{content_tag(:a, style: 'cursor: pointer; text-decoration: underline', onclick: %(window.location = #{dashboard_path.to_json})) { 'Check it out here.' }}
      </div>
    HEREDOC
  end
end

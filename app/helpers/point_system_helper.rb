# frozen_string_literal: true

module PointSystemHelper
  STRENGTH_LEVELS_FEATURE_UNLOCKS_AT_LEVEL_NUM = 2
  ANALYTICS_FEATURE_UNLOCKS_AT_LEVEL_NUM = 3
  COMMUNITY_FEATURE_UNLOCKS_AT_LEVEL_NUM = 4

  def current_level_percent_completed(user)
    @current_level_percent_completed ||= begin
      max_points_for_current_level = point_system(user).current_level.until
      user.total_points.to_f / max_points_for_current_level * 100
    end
  end

  def current_level_num(user)
    point_system(user).current_level_num
  end

  def next_level_num(user)
    point_system(user).next_level_num
  end

  def max_points_for_current_level(user)
    point_system(user).max_points_for_current_level
  end

  def total_levels_count(user = nil)
    point_system(user).total_levels_count
  end

  def strength_levels_feature_unlocked?
    @strength_levels_feature_unlocked ||= current_level_num(current_user) >= STRENGTH_LEVELS_FEATURE_UNLOCKS_AT_LEVEL_NUM
  end

  def community_feature_unlocked?
    @community_feature_unlocked ||= current_level_num(current_user) >= COMMUNITY_FEATURE_UNLOCKS_AT_LEVEL_NUM
  end

  def analytics_feature_unlocked?
    @analytics_feature_unlocked ||= current_level_num(current_user) >= ANALYTICS_FEATURE_UNLOCKS_AT_LEVEL_NUM
  end

  private

  def point_system(user)
    @point_system ||= ::PointSystem.new(user).parse!
  end
end

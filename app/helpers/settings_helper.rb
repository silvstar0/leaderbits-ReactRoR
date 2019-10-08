# frozen_string_literal: true

module SettingsHelper
  def points_over_time(user)
    user.points.order(created_at: :asc).each_with_object({}) do |point, result|
      key = point.created_at.noon.to_i

      if result[key].present?
        result[key] += point.value
      else
        latest_max_point_count = if result.keys.last.present?
                                   result[result.keys.last]
                                 else
                                   0
                                 end

        result[key] = latest_max_point_count + point.value
      end
    end
  end

  def momentum_over_time(user)
    user.momentum_historic_values.order(created_on: :asc).each_with_object({}) do |momentum_historic_value, result|
      key = momentum_historic_value.created_on.noon.to_i

      result[key] = momentum_historic_value.value
    end
  end
end

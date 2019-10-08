# frozen_string_literal: true

module HasUsersToSendLeaderbitsTo
  extend ActiveSupport::Concern

  included do
    private_class_method :time_now_in_user_tz
    #private_class_method :send_during_this_hour?
  end

  class_methods do
    def send_during_this_hour?(user)
      day_of_week_matches = time_now_in_user_tz(user).strftime('%A') == user.day_of_week_to_send
      return false unless day_of_week_matches

      hour_matches = time_now_in_user_tz(user).hour == user.hour_of_day_to_send
      return false unless hour_matches

      true
    end

    def time_now_in_user_tz(user)
      Time.now.in_time_zone ActiveSupport::TimeZone[user.time_zone]
    end
  end
end

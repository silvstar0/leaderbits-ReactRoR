# frozen_string_literal: true

class HourlySendingOfBoomerang
  def self.call
    boomerang_leaderbits = BoomerangLeaderbit
                             .where.not(type: BoomerangLeaderbit::Types::NEVER)
                             .where(user_id: User.active_recipient.pluck(:id))

    boomerang_leaderbits.each do |boomerang_leaderbit|
      next unless boomerang_leaderbit.boomerang_to_be_sent_on_date == Date.today && matches_user_hour_setting?(boomerang_leaderbit.user)

      LeaderbitMailer
        .with(leaderbit: boomerang_leaderbit.leaderbit, user: boomerang_leaderbit.user)
        .boomerang
        .deliver_later

      UserSentBoomerang.create!  user: boomerang_leaderbit.user,
                                 leaderbit: boomerang_leaderbit.leaderbit
    end
  end

  def self.matches_user_hour_setting?(user)
    hour_matches = time_now_in_user_tz(user).hour == user.hour_of_day_to_send
    hour_matches
  end

  def self.time_now_in_user_tz(user)
    Time.now.in_time_zone ActiveSupport::TimeZone[user.time_zone]
  end

  private_class_method :time_now_in_user_tz
end

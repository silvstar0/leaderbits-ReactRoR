# frozen_string_literal: true

module HasLatelyInactiveLeaders
  extend ActiveSupport::Concern

  class_methods do
    def recently_inactive_leader_users
      #TODO schedule_id check

      User
        .active_recipient
        .where('users.email NOT IN(?)', %w(jim.fetters0@gmail.com joeljoel@logic17.com nickdev@leaderbits.io joel@beasleyfoundation.org joel@moderncto.io joel3@leaderbits.io bryan@decisely.com chris.clemons@logrhythm.com))
        .inactive_for_last_14_days
    end
  end
end

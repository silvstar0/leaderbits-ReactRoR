# frozen_string_literal: true

module ActsAsIntercomUser
  extend ActiveSupport::Concern

  included do
    validates :intercom_user_id, uniqueness: true, allow_nil: true, allow_blank: false
  end

  def schedule_type
    schedule&.name
  end

  # @return [Hash]
  # @see IntercomData::CUSTOM_ATTRIBUTES
  def intercom_custom_data
    {
      # top-level user attributes
      name: name,
      email: email,

      # custom attributes:
      admin_page: Rails.application.routes.url_helpers.admin_user_url(self, host: 'app.leaderbits.io'),
      company_account_type: organization.account_type,
      completed_leaderbits_count: leaderbit_logs.completed.uniq.count,
      last_challenge_completed: last_completed_leaderbit_as_string,
      momentum: "#{momentum}%",
      points: total_points,
      schedule_type: schedule_type,
      time_zone: time_zone,
      upcoming_challenge: upcoming_challenge_as_string,
      uuid: uuid
    }
  end

  def upcoming_challenge_as_string
    Rails.cache.fetch "#{__method__}/#{cache_key_with_version}" do
      leaderbit = next_leaderbit_to_send

      leaderbit&.name.to_s.gsub('Challenge: ', '')
    end
  end
end

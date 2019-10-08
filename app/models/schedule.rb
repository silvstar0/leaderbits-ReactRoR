# frozen_string_literal: true

# == Schema Information
#
# Table name: schedules
#
#  id             :bigint(8)        not null, primary key
#  name           :string           not null
#  cloned_from_id :bigint(8)
#  users_count    :integer          default(0)
#
# Foreign Keys
#
#  fk_rails_...  (cloned_from_id => schedules.id)
#

class Schedule < ApplicationRecord
  GLOBAL_NAME = 'Global'

  audited

  has_many :users
  has_many :leaderbit_schedules, dependent: :delete_all
  has_many :leaderbits, through: :leaderbit_schedules

  validates :name, presence: true, allow_nil: false, allow_blank: false
  validates :name, uniqueness: { case_sensitive: false }

  after_save :invalidate_users_cache

  # @return [String]
  def cloned_from_schedule_name
    return '' if cloned_from_id.blank?

    @cloned_from_schedule_name ||= Schedule.find(cloned_from_id).name
  end

  # This method is needed for proper intercom user-syncing
  def invalidate_users_cache
    users.reload.map(&:touch)
  end
end

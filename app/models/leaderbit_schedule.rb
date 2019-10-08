# frozen_string_literal: true

# == Schema Information
#
# Table name: leaderbit_schedules
#
#  id           :bigint(8)        not null, primary key
#  leaderbit_id :bigint(8)        not null
#  schedule_id  :bigint(8)        not null
#  position     :integer
#
# Foreign Keys
#
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (schedule_id => schedules.id)
#

class LeaderbitSchedule < ApplicationRecord
  belongs_to :schedule
  belongs_to :leaderbit

  audited

  # @see https://github.com/swanandp/acts_as_list
  acts_as_list scope: :schedule

  after_save :touch_schedule
  after_destroy :touch_schedule

  private

  def touch_schedule
    schedule.invalidate_users_cache
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: leaderbit_logs
#
#  id           :bigint(8)        not null, primary key
#  leaderbit_id :bigint(8)        not null
#  user_id      :bigint(8)        not null
#  status       :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (user_id => users.id)
#

class LeaderbitLog < ApplicationRecord
  INDIVIDUAL_REPORT_ON_N_COMPLETED_CHALLENGES = 3

  belongs_to :leaderbit
  belongs_to :user, touch: true

  module Statuses
    IN_PROGRESS = 'in_progress'
    COMPLETED = 'completed'

    ALL = [IN_PROGRESS, COMPLETED].freeze
  end

  validates :status, inclusion: { in: Statuses::ALL }
  validates :status, uniqueness: { scope: %i[user_id leaderbit_id] }

  enum status: LeaderbitLog::Statuses::ALL.each_with_object({}) { |v, h| h[v] = v }

  # @return [LeaderbitLog] that's important
  def self.create_with_in_progress_status_and_assign_points!(user:, leaderbit:)
    LeaderbitLog.create!(user: user,
                         leaderbit: leaderbit,
                         status: LeaderbitLog::Statuses::IN_PROGRESS).tap do
      Point.create!(user: user,
                    pointable: leaderbit,
                    value: rand(25..31),
                    type: Point::Types::STARTED_LEADERBIT)
    end
  end
end

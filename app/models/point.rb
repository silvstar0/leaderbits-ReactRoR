# frozen_string_literal: true

# == Schema Information
#
# Table name: points
#
#  id             :bigint(8)        not null, primary key
#  user_id        :bigint(8)        not null
#  value          :integer          not null
#  type           :string           not null
#  pointable_type :string           not null
#  pointable_id   :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Point < ApplicationRecord
  # leaderbit or entry
  belongs_to :pointable, polymorphic: true

  # mostly for total_points(sum) results caching which is used frequently
  belongs_to :user, touch: true

  def self.inheritance_column
    nil
  end

  module Types
    STARTED_LEADERBIT = 'started_leaderbit'
    REFLECT_ENTRY = 'reflect_entry'

    ALL = [
      STARTED_LEADERBIT,
      REFLECT_ENTRY
    ].freeze
  end

  validates :type, inclusion: { in: Types::ALL }
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: boomerang_leaderbits
#
#  id           :bigint(8)        not null, primary key
#  type         :string           not null
#  user_id      :bigint(8)        not null
#  leaderbit_id :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (user_id => users.id)
#

# Why is it a separate table and not just a column for entries table?
# Joel said that boomerang feature is (user;leaderbit) level in this case
class BoomerangLeaderbit < ApplicationRecord
  belongs_to :leaderbit
  belongs_to :user

  module Types
    COUPLE_DAYS = 'couple_days'
    TWO_WEEKS = 'two_weeks'
    ONE_MONTH = 'one_month'
    NEVER = 'never'

    DEFAULT = NEVER.freeze

    ALL = [
      COUPLE_DAYS,
      TWO_WEEKS,
      ONE_MONTH,
      NEVER
    ].freeze
  end

  validates :type, presence: true, allow_nil: false, allow_blank: false
  validates :type, inclusion: { in: Types::ALL }

  #TODO switch to enum for types after we switch to Rails6(negative scopes on enum needed here)

  validates :type, uniqueness: { scope: %i[leaderbit user] }

  def self.boomerang_value_to_title(value)
    {
      Types::COUPLE_DAYS => 'in a couple days',
      Types::TWO_WEEKS => 'In 2 weeks',
      Types::ONE_MONTH => 'Next month',
      Types::NEVER => 'Never'
    }.fetch(value)
  end

  def boomerang_to_be_sent_on_date
    case type
    when Types::COUPLE_DAYS
      created_at_day_name = Date::DAYNAMES[created_at.wday]

      case created_at_day_name
      when 'Monday'
        created_at.to_date.next_occurring(:wednesday)
      when 'Tuesday'
        created_at.to_date.next_occurring(:thursday)
      when 'Wednesday'
        created_at.to_date.next_occurring(:friday)
      when 'Thursday'
        created_at.to_date.next_occurring(:monday)
      when 'Friday'
        created_at.to_date.next_occurring(:tuesday)
      when 'Saturday'
        created_at.to_date.next_occurring(:tuesday)
      when 'Sunday'
        created_at.to_date.next_occurring(:wednesday)
      else
        raise created_at_day_name.to_s
      end
    when Types::TWO_WEEKS
      2.weeks.since(created_at).to_date
    when Types::ONE_MONTH
      1.month.since(created_at).to_date
    else
      raise type.inspect
    end
  end

  def self.inheritance_column
    nil
  end
end

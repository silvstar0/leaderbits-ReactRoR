# frozen_string_literal: true

# == Schema Information
#
# Table name: momentum_historic_values
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  value      :integer          not null
#  created_on :date             not null
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class MomentumHistoricValue < ApplicationRecord
  belongs_to :user

  validates :created_on, uniqueness: { scope: :user }
  validates :value, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: false, allow_blank: false
end

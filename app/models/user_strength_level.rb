# frozen_string_literal: true

# == Schema Information
#
# Table name: user_strength_levels
#
#  id          :bigint(8)        not null, primary key
#  symbol_name :string
#  user_id     :bigint(8)        not null
#  value       :integer
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class UserStrengthLevel < ApplicationRecord
  belongs_to :user

  # TODO pull levels from formobject class to this model?
  validates :symbol_name, inclusion: { in: StrengthLevelsFormObject::Levels::ALL }

  validates :user, presence: true, allow_nil: false, allow_blank: false

  validates :symbol_name, uniqueness: { scope: :user }
end

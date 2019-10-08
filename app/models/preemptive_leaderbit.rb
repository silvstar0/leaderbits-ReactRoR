# frozen_string_literal: true1

# == Schema Information
#
# Table name: preemptive_leaderbits
#
#  id               :bigint(8)        not null, primary key
#  leaderbit_id     :bigint(8)        not null
#  user_id          :bigint(8)        not null
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  added_by_user_id :bigint(8)        not null
#
# Foreign Keys
#
#  fk_rails_...  (added_by_user_id => users.id)
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (user_id => users.id)
#

class PreemptiveLeaderbit < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :leaderbit
  belongs_to :added_by_user, class_name: 'User'

  audited

  # @see https://github.com/swanandp/acts_as_list
  acts_as_list scope: :user

  with_options allow_nil: false, allow_blank: false do
    validates :leaderbit, presence: true
    validates :user, presence: true
    validates :added_by_user, presence: true
  end

  validates :leaderbit, uniqueness: { scope: :user }
end

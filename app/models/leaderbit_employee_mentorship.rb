# frozen_string_literal: true

# == Schema Information
#
# Table name: leaderbit_employee_mentorships
#
#  id             :bigint(8)        not null, primary key
#  mentor_user_id :bigint(8)
#  mentee_user_id :bigint(8)
#  created_at     :datetime
#
# Foreign Keys
#
#  fk_rails_...  (mentee_user_id => users.id)
#  fk_rails_...  (mentor_user_id => users.id)
#

class LeaderbitEmployeeMentorship < ApplicationRecord
  belongs_to :mentor_user, class_name: 'User', touch: true
  belongs_to :mentee_user, class_name: 'User', touch: true

  audited

  validates :mentee_user, uniqueness: { scope: :mentor_user }, allow_blank: false, allow_nil: false
end

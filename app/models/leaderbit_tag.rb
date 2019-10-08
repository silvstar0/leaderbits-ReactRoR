# frozen_string_literal: true

# == Schema Information
#
# Table name: leaderbit_tags
#
#  id           :bigint(8)        not null, primary key
#  label        :string           not null
#  leaderbit_id :bigint(8)        not null
#  created_at   :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#

class LeaderbitTag < ApplicationRecord
  belongs_to :leaderbit

  audited

  validates :label, uniqueness: { scope: :leaderbit }, presence: true
end

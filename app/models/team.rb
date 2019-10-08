# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id              :bigint(8)        not null, primary key
#  name            :string           not null
#  organization_id :bigint(8)        not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#

class Team < ApplicationRecord
  belongs_to :organization, touch: true

  has_many :team_members, dependent: :destroy

  with_options allow_nil: false, allow_blank: false do
    validates :name, presence: true
    #TODO temporary disabled - why names are not unique in old orgs?
    #validates :name, uniqueness: { scope: :organization, case_sensitive: false }
  end

  def users
    TeamMember.includes(:user).where(team: self).collect(&:user)
  end

  # @return [ActiveRecord::Relation]
  def users_who_can_be_added
    organization
      .users
      .where.not(schedule: nil).where('users.id NOT IN(SELECT user_id FROM team_members WHERE team_id = ?)', id)
  end
end

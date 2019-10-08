# frozen_string_literal: true

# == Schema Information
#
# Table name: entry_groups
#
#  id           :bigint(8)        not null, primary key
#  leaderbit_id :bigint(8)        not null
#  user_id      :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (user_id => users.id)
#

class EntryGroup < ApplicationRecord
  belongs_to :leaderbit
  belongs_to :user # TODO handle counter_cache?

  with_options dependent: :destroy do
    has_many :entries
  end

  has_many :user_seen_entry_groups, dependent: :delete_all

  #TODO after save invalidate cache of all user seen entry groups? then it can cache it

  validates :leaderbit, uniqueness: { scope: :user }

  def self.unseen_by_user(user)
    where("entry_groups.id NOT IN (SELECT entry_group_id FROM user_seen_entry_groups WHERE user_id = ?)", user.id)
  end

  def self.exclude_discarded_users
    joins(:user)
      .where('users.discarded_at IS NULL')
  end

  def self.visible_in_my_teams(user)
    team_ids = TeamMember.where(user: user.id).pluck(:team_id) || [-1]

    where('user_id IN(SELECT user_id FROM team_members WHERE team_id IN(?))', team_ids)
  end
  #private_class_method :visible_in_my_teams
end

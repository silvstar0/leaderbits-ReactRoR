# frozen_string_literal: true

# == Schema Information
#
# Table name: user_seen_entry_groups
#
#  id             :bigint(8)        not null, primary key
#  user_id        :bigint(8)        not null
#  entry_group_id :bigint(8)        not null
#  created_at     :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (entry_group_id => entry_groups.id)
#  fk_rails_...  (user_id => users.id)
#

class UserSeenEntryGroup < ApplicationRecord
  belongs_to :user, touch: true #important
  belongs_to :entry_group

  validates :user, presence: true, allow_nil: false, allow_blank: false
  validates :entry_group, presence: true, allow_nil: false, allow_blank: false
end

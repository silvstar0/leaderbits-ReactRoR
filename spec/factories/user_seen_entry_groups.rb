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

FactoryBot.define do
  factory :user_seen_entry_group do
    user
    entry_group
  end
end

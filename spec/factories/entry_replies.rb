# frozen_string_literal: true

# == Schema Information
#
# Table name: entry_replies
#
#  id                      :bigint(8)        not null, primary key
#  user_id                 :bigint(8)        not null
#  entry_id                :bigint(8)        not null
#  content                 :text             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  parent_reply_id         :integer
#  cached_votes_total      :integer          default(0)
#  cached_votes_score      :integer          default(0)
#  cached_votes_up         :integer          default(0)
#  cached_votes_down       :integer          default(0)
#  cached_weighted_score   :integer          default(0)
#  cached_weighted_total   :integer          default(0)
#  cached_weighted_average :float            default(0.0)
#
# Foreign Keys
#
#  fk_rails_...  (entry_id => entries.id)
#  fk_rails_...  (parent_reply_id => entry_replies.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :entry_reply do
    user
    association :entry, factory: :kept_entry
    content do
      Faker::Hacker.say_something_smart + ' ' + ([true, false].sample ? Faker::Internet.url(scheme: 'https', host: 'app.leaderbits.com') : '')
    end
    parent_reply_id { nil }
  end
end

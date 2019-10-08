# frozen_string_literal: true

# == Schema Information
#
# Table name: entries
#
#  id                                                                                                                          :bigint(8)        not null, primary key
#  leaderbit_id                                                                                                                :bigint(8)        not null
#  content                                                                                                                     :text             not null
#  user_id                                                                                                                     :bigint(8)        not null
#  created_at                                                                                                                  :datetime         not null
#  updated_at                                                                                                                  :datetime         not null
#  cached_votes_total                                                                                                          :integer          default(0)
#  cached_votes_score                                                                                                          :integer          default(0)
#  cached_votes_up                                                                                                             :integer          default(0)
#  cached_votes_down                                                                                                           :integer          default(0)
#  cached_weighted_score                                                                                                       :integer          default(0)
#  cached_weighted_total                                                                                                       :integer          default(0)
#  cached_weighted_average                                                                                                     :float            default(0.0)
#  entry_group_id                                                                                                              :bigint(8)        not null
#  content_updated_at(needed to reliably separate actual content update time from nested :touch => true ActiveRecord triggers) :datetime
#  visible_to_my_mentors                                                                                                       :boolean          default(FALSE), not null
#  visible_to_my_peers                                                                                                         :boolean          default(FALSE), not null
#  visible_to_community_anonymously                                                                                            :boolean          default(FALSE), not null
#  discarded_at                                                                                                                :datetime
#
# Foreign Keys
#
#  fk_rails_...  (entry_group_id => entry_groups.id)
#  fk_rails_...  (leaderbit_id => leaderbits.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :entry do
    leaderbit
    user
    content do
      [Faker::Movies::HitchhikersGuideToTheGalaxy.marvin_quote, Faker::Movies::HitchhikersGuideToTheGalaxy.quote]
        .sample
        .gsub("'", "") #because otherwise have_content gives false failures
    end

    discarded_at { [2.seconds.ago, nil].sample }

    visible_to_my_mentors { [true, false].sample }
    visible_to_my_peers { [true, false].sample }
    visible_to_community_anonymously { [true, false].sample }

    after(:build) do |entry, _evaluator|
      entry.entry_group = build(:entry_group, leaderbit: entry.leaderbit, user: entry.user) if entry.entry_group.nil?
    end
  end

  factory :kept_entry, parent: :entry do
    discarded_at { nil }
  end
end

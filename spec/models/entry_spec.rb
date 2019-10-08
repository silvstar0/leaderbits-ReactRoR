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

require 'rails_helper'

RSpec.describe Entry, type: :model do
  describe 'voting cache key handling' do
    it 'does not affect cache_key version' do
      user = create(:user)

      entry = create(:entry, discarded_at: nil)
      entry2 = create(:entry, discarded_at: nil)

      expect { entry.liked_by user }.to change { entry.reload.cache_key_with_version }
      expect { entry2.liked_by user }.not_to change { user.reload.cache_key_with_version }
    end
  end

  describe 'content_updated_at touching' do
    example do
      entry = create(:entry, discarded_at: nil)

      expect(entry.reload.content_updated_at).to eq(nil)

      entry.content = 'hello world upd'
      entry.save!

      expect(entry.reload.content_updated_at).to be_present
    end
  end

  # describe '#after_destroy' do
  #   it 'last entry deletes entry group' do
  #     user = create(:user)
  #
  #     entry_group = create(:entry_group, user: user)
  #
  #     entry1 = create(:entry, leaderbit: entry_group.leaderbit, user: user, entry_group: entry_group)
  #     entry2 = create(:entry, leaderbit: entry_group.leaderbit, user: user, entry_group: entry_group)
  #
  #     expect { entry1.destroy }.to change { entry_group.entries.reload.count }.from(2).to(1)
  #     expect { entry2.destroy }.to change(EntryGroup, :count).from(1).to(0)
  #   end
  # end
end

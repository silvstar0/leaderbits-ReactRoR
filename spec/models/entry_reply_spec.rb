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

require 'rails_helper'

RSpec.describe EntryReply, type: :model do
  describe 'voting cache key handling' do
    it 'does not affect cache_key version' do
      user = create(:user)

      reply = create(:entry_reply)
      reply2 = create(:entry_reply)
      reply3 = create(:entry_reply)

      expect { reply.liked_by user }.to change { user.voted_for?(reply) }.from(false).to(true)
                                          .and change { reply.reload.cache_key_with_version }

      expect { reply2.liked_by user }.not_to change { user.reload.cache_key_with_version }

      expect { reply3.liked_by user }.to change { reply3.entry.reload.cache_key_with_version }
    end
  end

  describe '#create' do
    subject { -> { create(:entry_reply, user: user, entry: entry) } }

    let!(:user) { create(:user) }
    let!(:entry) { create(:entry, discarded_at: nil) }

    it "marks it as seen for author" do
      expect{ subject.call }.to change(described_class, :count).to(1)
                                  .and change { UserSeenEntryGroup.where(user: user, entry_group: entry.entry_group).count }.to(1)
    end

    it 'invalidate seen cache on reply creation' do
      user1 = create(:user)
      create(:user)

      UserSeenEntryGroup.create! entry_group: entry.entry_group, user: user1

      expect{ subject.call }.to change { UserSeenEntryGroup.where(user: user1, entry_group: entry.entry_group).count }.from(1).to(0)
    end

    it 'invalidated entry user cache' do
      expect{ subject.call }.to change { entry.user.updated_at }
    end

    it 'mailer notifies' do
      entry_reply = build(:entry_reply, user: user)

      expect {
        entry_reply.save
      }.to change { ActionMailer::Base.deliveries.count }.from(0).to(1)
             .and change { ActionMailer::Base.deliveries.last&.subject }.from(nil).to("#{entry_reply.user.name} Replied to You - #{entry_reply.entry.leaderbit.name}")
    end
  end
end

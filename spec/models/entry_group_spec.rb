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

require 'rails_helper'

RSpec.describe EntryGroup, type: :model do
  describe 'ss' do
    subject { -> { described_class.where('entry_groups.id IN(SELECT entry_group_id FROM entries WHERE discarded_at IS NULL)') } }

    let(:user) { create(:user) }

    example do
      create(:entry_group, user: user)
      expect(subject.call).to be_blank

      leaderbit = create(:leaderbit)
      eg2 = create(:entry_group, user: user, leaderbit: leaderbit)
      create(:entry, entry_group: eg2, discarded_at: Time.now, user: user, leaderbit: leaderbit)

      expect(subject.call).to be_blank

      create(:entry, entry_group: eg2, discarded_at: nil, user: user, leaderbit: leaderbit)

      expect(subject.call).to contain_exactly(eg2)
    end
  end

  describe '.unseen_by_user(user)' do
    example do
      user = create(:user)

      entry_group1 = create(:entry_group, user: user)

      entry_group2 = create(:entry_group, user: user)
      entry_group3 = create(:entry_group, user: user)

      create(:user_seen_entry_group, user: user, entry_group: entry_group1 )

      actual = described_class.unseen_by_user(user)
      expect(actual).to match_array([entry_group2, entry_group3])
    end
  end

  # describe '.visible_for_user' do
  #   def verify_when_leader
  #     @user = create(:team_leader_user)
  #     team = Team.first!
  #
  #     user1 = create(:user, organization: @user.organization).tap { |u| TeamMember.create! role: TeamMember::Roles::MEMBER, user: u, team: team }
  #     @entry1 = create(:entry, visible_to_my_peers: true, user: user1)
  #
  #     user2 = create(:user).tap { |u| TeamMember.create! role: TeamMember::Roles::MEMBER, user: u, team: create(:team) }
  #     create(:entry, visible_to_my_peers: true, user: user2)
  #
  #     #expect(described_class.visible_by_team_leader(team_leader_user)).to contain_exactly(entry1.entry_group)
  #     expect(described_class.high_level_user_role_base_scope(@user)).to contain_exactly(@entry1.entry_group)
  #   end
  #
  #   context 'when team leader' do
  #     example do
  #       verify_when_leader
  #     end
  #
  #     #the goal of this spec to verify MIXED role - anyone really + mentor. Result has to include both groups
  #     context 'and also mentor' do
  #       example do
  #         verify_when_leader
  #
  #         user4 = create(:user, organization: @user.organization)
  #         create :organizational_mentorship, mentor_user: @user, mentee_user: user4, accepted_at: Time.now
  #
  #         entry2 = create(:entry, visible_to_my_peers: true, user: user4)
  #
  #         expect(described_class.high_level_user_role_base_scope(@user)).to contain_exactly(@entry1.entry_group, entry2.entry_group)
  #       end
  #     end
  #   end
  #
  #   context 'C-level user' do
  #     example do
  #       organization = create(:organization)
  #       user = create(:c_level_user, organization: organization)
  #
  #       user1 = create(:user, organization: organization)
  #       user2 = create(:user, organization: organization)
  #       user3 = create(:user)
  #
  #       entry1 = create(:entry, visible_to_my_peers: true, user: user1)
  #       entry2 = create(:entry, visible_to_my_peers: false, user: user2)
  #       create(:entry, user: user3, visible_to_my_peers: true)
  #
  #       expect(described_class.high_level_user_role_base_scope(user)).to contain_exactly(entry1.entry_group, entry2.entry_group)
  #     end
  #   end
  #end
end

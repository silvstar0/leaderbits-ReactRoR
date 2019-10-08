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

require 'rails_helper'

RSpec.describe Team, type: :model do
  let(:team) { create(:team) }

  describe 'cache invalidation' do
    example do
      organization = create(:organization)

      expect { create(:team, organization: organization) }.to change { organization.reload.cache_key_with_version }
    end
  end

  describe '#users' do
    example do
      team1 = create(:team)
      team2 = create(:team)

      user1 = create(:user)
      user2 = create(:user)
      create(:user)

      TeamMember.create! role: TeamMember::Roles::LEADER, user: user1, team: team1
      TeamMember.create! role: TeamMember::Roles::MEMBER, user: user2, team: team1

      expect(team1.users).to contain_exactly(user1, user2)
      expect(team2.users).to be_blank
    end
  end
end

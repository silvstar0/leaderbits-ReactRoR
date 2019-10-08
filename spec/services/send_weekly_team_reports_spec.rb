# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendWeeklyTeamReports do
  let(:organization) { create(:organization, leaderbits_sending_enabled: true) }

  context 'given one-person team' do
    it 'skips notification' do
      team1 = create(:team, organization: organization)
      create(:user,
             created_at: 20.days.ago,
             organization: organization)
        .tap { |u| TeamMember.create! user: u, team: team1, role: TeamMember::Roles::ALL.sample }

      expect { described_class.call }.not_to change(UserSentEmail, :count)
    end
  end

  context 'given at least 2-person team' do
    it 'notifies everyone' do
      team1 = create(:team, organization: organization)
      user1 = create(:user,
                     created_at: 20.days.ago,
                     organization: organization)
                .tap { |u| TeamMember.create! user: u, team: team1, role: TeamMember::Roles::ALL.sample }

      user2 = create(:user,
                     created_at: 20.days.ago,
                     organization: organization)
                .tap { |u| TeamMember.create! user: u, team: team1, role: TeamMember::Roles::ALL.sample }

      expect { described_class.call }.to change(UserSentEmail, :count).to(2)
                                           .and change { ActionMailer::Base.deliveries.collect(&:subject) }.to(["Weekly summary", "Weekly summary"])
                                                  .and change { ActionMailer::Base.deliveries.collect(&:to).flatten.sort }.to([user1.email, user2.email].sort)
    end

    it 'does not notify teams with new users' do
      team1 = create(:team, organization: organization)
      create(:user,
             created_at: 2.days.ago,
             organization: organization)
        .tap { |u| TeamMember.create! user: u, team: team1, role: TeamMember::Roles::ALL.sample }
      create(:user,
             created_at: 2.days.ago,
             organization: organization)
        .tap { |u| TeamMember.create! user: u, team: team1, role: TeamMember::Roles::ALL.sample }

      expect { described_class.call }.not_to change(UserSentEmail, :count)
    end
  end
end

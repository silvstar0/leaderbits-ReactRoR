# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateEntry, type: :model do
  describe '#call after_create' do
    subject do
      -> {
        entry_params = build(:entry, leaderbit: leaderbit).attributes.except('id', 'user', 'user_id', 'discarded_at')

        create_entry = described_class.new
        create_entry.with_step_args(validate: [current_user: user]).call(leaderbit_id: leaderbit.id, entry: entry_params)
      }
    end

    let(:entry_params) { build(:entry, leaderbit: leaderbit).attributes.except('id', 'user', 'user_id', 'discarded_at') }
    let(:entry_group) { create(:entry_group, user: user, leaderbit: leaderbit) }
    let(:leaderbit) { create(:leaderbit) }
    let!(:user) { create(:user) }

    it "adds points after an entry is created" do
      expect{ subject.call }.to change { user.reload.total_points }.from(0)
                                  .and change { user.reload.total_points }.by_at_least(25 + 90)
                                         .and change { user.reload.total_points }.by_at_most(96 + 31)
    end

    it "marks it as seen for author" do
      expect{ subject.call }.to change { UserSeenEntryGroup.where(user: user).count }.to(1)
    end

    it "doesnt add points more than once per completed leaderbit" do
      subject.call
      base_points = user.total_points

      expect { subject.call }.not_to change { user.reload.total_points }.from(base_points)
    end

    context 'with in-progress leaderbit log' do
      it 'marks leaderbit log as completed and invalidates user cache_key' do
        llog = create(:leaderbit_log, user: user, leaderbit: leaderbit, status: LeaderbitLog::Statuses::IN_PROGRESS, updated_at: nil)

        expect { subject.call }.to change { llog.reload.status }.to(LeaderbitLog::Statuses::COMPLETED)
                                     .and change(llog, :updated_at)
                                            .and change { user.reload.cache_key_with_version }
      end
    end

    context 'with leaderbits_sending_enabled=false mentor' do
      let(:organization) { user.organization }

      it 'email-notifies mentors on first entry' do
        mentor_user1 = create(:user, organization: organization, leaderbits_sending_enabled: false)
        mentor_user2 = create(:user, organization: organization, leaderbits_sending_enabled: false)

        OrganizationalMentorship.create! mentor_user: mentor_user1, mentee_user: user
        OrganizationalMentorship.create! mentor_user: mentor_user2, mentee_user: user

        # not notified because not related to the new entry
        OrganizationalMentorship.create! mentor_user: create(:user, organization: organization), mentee_user: create(:user, organization: organization)

        expect {
          subject.call
        }.to change { ActionMailer::Base.deliveries.count }.to(2)
               .and change { ActionMailer::Base.deliveries.collect(&:subject) }.to(["New entry for you to review", "New entry for you to review"])

        #and does not notify on the second one
        expect {
          subject.call
        }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end

    context 'with leaderbits_sending_enabled=false team leader' do
      let(:organization) { user.organization }

      it 'email-notifies team leaders on first entry in their team' do
        # no need to notify leader1 because he receives magic links emails anyway
        team_leader1 = create(:user, organization: organization, leaderbits_sending_enabled: true)

        team_leader2 = create(:user, organization: organization, leaderbits_sending_enabled: false)

        team = create(:team, organization: organization)

        TeamMember.create! user: user, team: team, role: TeamMember::Roles::MEMBER

        TeamMember.create! user: team_leader1, team: team, role: TeamMember::Roles::LEADER
        TeamMember.create! user: team_leader2, team: team, role: TeamMember::Roles::LEADER

        expect {
          subject.call
        }.to change { ActionMailer::Base.deliveries.count }.to(1)
               .and change { ActionMailer::Base.deliveries.collect(&:subject) }.to(["New entry for you to review"])

        expect(ActionMailer::Base.deliveries.last.to).to eq([team_leader2.email])

        #and does not notify on the second one
        expect {
          subject.call
        }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end
  end
end

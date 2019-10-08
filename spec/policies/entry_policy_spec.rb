# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntryPolicy do
  subject { described_class.new(user, entry) }

  #NOTE: these specs have been commented out because this policy action is now available for everyone
  # describe 'index' do
  #   context 'given system admin' do
  #     let(:user) { create(:system_admin_user) }
  #     let(:entry) { Entry }
  #
  #     it { is_expected.to permit_action(:index) }
  #   end
  #
  #   context 'given team leader' do
  #     let(:user) { create(:team_leader_user) }
  #     let(:entry) { Entry }
  #
  #     it { is_expected.to permit_action(:index) }
  #   end
  #
  #   context 'given team member' do
  #     let(:user) { create(:team_member_user) }
  #     let(:entry) { Entry }
  #
  #     it { is_expected.to forbid_action(:index) }
  #   end
  # end

  # NOTE: spec has been commented out because everyone is currently allowed to like everything
  # there is high chance that it would change in the future so just uncomment the following if/when this moment comes
  # describe 'toggle_like' do
  #   context 'given system admin' do
  #     let(:user) { create(:system_admin_user) }
  #     let(:entry) { build(:entry) }
  #
  #     it { is_expected.to permit_action(:toggle_like) }
  #   end
  #
  #   context 'given user who has access to that entry' do
  #     let(:user) { create(:user) }
  #     let(:entry) { create(:entry, discarded_at: nil) }
  #
  #     before do
  #       UserSeenEntryGroup.create! user: user, entry_group: entry.entry_group
  #     end
  #
  #     it { is_expected.to permit_action(:toggle_like) }
  #   end
  #
  #   context 'given outsider user' do
  #     let(:user) { create(:user) }
  #     let(:entry) { create(:entry, discarded_at: nil) }
  #
  #     it { is_expected.to permit_action(:toggle_like) }
  #   end
  # end

  describe 'reply_to' do
    context 'given system admin' do
      let(:user) { create(:system_admin_user) }
      let(:entry) { create(:entry, discarded_at: nil) }

      it { is_expected.to permit_action(:reply_to) }
    end

    context 'signed in as c-level, same organization user' do
      let(:user) { create(:c_level_user) }
      let(:user2) { create(:user, organization: user.organization) }
      let(:entry) { create(:entry, user: user2) }

      it { is_expected.to permit_action(:reply_to) }
    end

    context 'signed in as c-level, different organization user' do
      let(:user) { create(:c_level_user) }
      let(:entry) { create(:entry, discarded_at: nil) }

      it { is_expected.to forbid_action(:reply_to) }
    end

    context 'given team leader and his teams entry' do
      let(:user) { create(:team_leader_user) }
      let(:user2) do
        create(:user,
               organization: user.organization)
          .tap { |user| TeamMember.create! user: user, role: TeamMember::Roles::MEMBER, team: Team.first! }
      end

      let(:entry) { create(:entry, user: user2) }

      it { is_expected.to permit_action(:reply_to) }
    end

    context 'given team member and his other team member entry' do
      let(:user) { create(:team_member_user) }
      let(:user2) do
        create(:user,
               organization: user.organization)
          .tap { |user| TeamMember.create! user: user, role: TeamMember::Roles::MEMBER, team: Team.first! }
      end

      let(:entry) { create(:entry, user: user2) }

      it { is_expected.to permit_action(:reply_to) }
    end

    context 'given team leader and not his teams entry' do
      let(:user) { create(:team_leader_user) }
      let(:entry) { create(:entry, discarded_at: nil) }

      it { is_expected.to forbid_action(:reply_to) }
    end

    context 'given progress report recipient' do
      let(:organization) { create(:organization) }
      let(:user) do
        u = User.new(email: Faker::Internet.email,
                     name: Faker::Name.name,
                     hour_of_day_to_send: 8,
                     day_of_week_to_send: 'Monday',
                     #technically these users don't need timezones at all
                     goes_through_leader_welcome_video_onboarding_step: false,
                     goes_through_leader_strength_finder_onboarding_step: false,
                     goes_through_team_survey_360_onboarding_step: false,
                     goes_through_organizational_mentorship_onboarding_step: false,
                     time_zone: ActiveSupport::TimeZone.all.sample.name,
                     organization: organization)
        def u.password_required?
          false
        end
        u.save!
        #u.discard
        create(:progress_report_recipient, added_by_user: entry.user, user: u)
        u
      end
      let(:entry) { create(:entry, discarded_at: nil) }

      it { is_expected.to permit_action(:reply_to) }
    end
  end

  describe 'edit' do
    context 'given random user' do
      let(:user) { create(:user) }
      let(:entry) { create(:entry, discarded_at: nil) }

      it { is_expected.to forbid_action(:edit) }
    end

    context 'given user with entry reference' do
      let(:user) { entry.user }
      let(:entry) { create(:entry, discarded_at: nil) }

      it { is_expected.to permit_action(:edit) }
    end
  end

  #TODO update these specs to check for discarded entry presence. Spec is outdated
  describe 'destroy' do
    let(:leaderbit) { create(:leaderbit) }

    context 'given random user' do
      let(:user) { create(:user) }
      let!(:entry) { create(:entry, user: create(:user), leaderbit: leaderbit) }

      it { is_expected.to forbid_action(:destroy) }
    end

    context 'given user with entry fresh reference' do
      let(:user) { create(:user) }
      let!(:entry) { create(:entry, user: user, leaderbit: leaderbit, created_at: 1.minute.ago) }

      it { is_expected.to permit_action(:destroy) }
    end

    context 'given user with multiple fresh entries' do
      let(:user) { create(:user) }
      let(:entry_group) { create(:entry_group, user: user, leaderbit: leaderbit) }
      let!(:entry) { create(:entry, user: user, leaderbit: leaderbit, entry_group: entry_group, created_at: 1.minute.ago) }
      let!(:entry2) { create(:entry, user: user, leaderbit: leaderbit, entry_group: entry_group, created_at: 1.minute.ago) }

      it { is_expected.to permit_action(:destroy) }
    end

    context 'given user with entry old reference' do
      let(:user) { create(:user) }
      let!(:entry) { create(:entry, user: user, leaderbit: leaderbit, created_at: 2.days.ago) }

      it { is_expected.to permit_action(:destroy) }
    end
  end
end

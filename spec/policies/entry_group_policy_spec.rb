# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntryGroupPolicy do
  subject { described_class.new(user, entry_group) }

  describe '#mark_as_read' do
    context 'given system admin and unseen entry group' do
      let(:user) { create(:system_admin_user) }
      let(:entry_group) { create(:entry_group) }

      it { is_expected.to permit_action(:mark_as_read) }
    end

    context 'given system admin and seen entry' do
      let(:user) { create(:system_admin_user) }
      let(:entry_group) { create(:entry_group) }

      before { UserSeenEntryGroup.create! user: user, entry_group: entry_group }

      it { is_expected.to forbid_action(:mark_as_read) }
    end
  end

  describe '#show' do
    context 'given system admin and unseen entry group' do
      let(:user) { create(:system_admin_user) }
      #TODO improve, it randomly fails
      let(:entry_group) { create(:entry_group) }

      it { is_expected.to permit_action(:show) }
    end

    context 'given team leader and his team members entry group' do
      let(:entry_group) { create(:entry_group, user: user2) }
      let(:user) { create(:team_leader_user, organization: organization) }

      let(:organization) { create(:organization) }
      let(:user2) do
        create(:user,
               organization: organization)
          .tap { |u| TeamMember.create! user: u, role: TeamMember::Roles::MEMBER, team: Team.first! }
      end

      it { is_expected.to permit_action(:show) }
    end

    context 'given *technical user* progress report recipient visiting entry-details link' do
      let(:user) { progress_report_recipient.user }
      let(:entry_group) { create(:entry_group) }

      let(:progress_report_recipient) { create(:progress_report_recipient, added_by_user: entry_group.user) }

      it { is_expected.to permit_action(:show) }
    end

    context 'given author himself' do
      let(:entry_group) { create(:entry_group) }
      let(:user) { entry_group.user }

      it { is_expected.to permit_action(:show) }
    end

    context 'given mentor seeing his mentee entry group' do
      let(:entry_group) { create(:entry_group, user: organizational_mentorship.mentee_user) }
      let(:user) { organizational_mentorship.mentor_user }
      let(:organizational_mentorship) { create(:organizational_mentorship) }

      it { is_expected.to permit_action(:show) }
    end

    context 'given mentee user seeing his mentor entry group' do
      let(:entry_group) { create(:entry_group, user: organizational_mentorship.mentor_user) }
      let(:user) { organizational_mentorship.mentee_user }
      let(:organizational_mentorship) { create(:organizational_mentorship) }

      it { is_expected.to permit_action(:show) }
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class.new(user, record) }

  describe '#manage_preemptive_leaderbits_for' do
    let(:organization) { create(:organization) }

    context 'given system admin' do
      let(:user) { create(:system_admin_user, organization: organization) }
      let(:record) { create(:user, organization: organization) }

      it { is_expected.to permit_action(:manage_preemptive_leaderbits_for) }
    end

    context 'given regular user' do
      let(:user) { create(:user, organization: organization) }
      let(:record) { user }

      it { is_expected.to forbid_action(:manage_preemptive_leaderbits_for) }
    end

    context 'given team leader' do
      let!(:user) { create(:team_leader_user, organization: organization) }

      context 'and your teams member' do
        let(:record) do
          create(:user,
                 organization: organization)
            .tap { |u| TeamMember.create! team: Team.first!, user: u, role: TeamMember::Roles::MEMBER }
        end

        it { is_expected.to permit_action(:manage_preemptive_leaderbits_for) }
      end

      context 'and not your teams member' do
        let(:record) { create(:team_member_user, organization: organization) }

        it { is_expected.to forbid_action(:manage_preemptive_leaderbits_for) }
      end
    end
  end

  describe '#show' do
    let(:organization) { create(:organization) }

    context 'given system admin' do
      let(:user) { create(:system_admin_user, organization: organization) }
      let(:record) { create(:user, organization: organization) }

      it { is_expected.to permit_action(:show) }
    end

    context 'given regular user' do
      let(:user) { create(:user, organization: organization) }
      let(:record) { user }

      it { is_expected.to permit_action(:show) }
    end

    context 'given your mentee' do
      let!(:organizational_mentorship) { create(:organizational_mentorship) }

      let(:user) { organizational_mentorship.mentor_user }
      let(:record) { organizational_mentorship.mentee_user }

      it { is_expected.to permit_action(:show) }
    end

    context 'given team leader' do
      let!(:user) { create(:team_leader_user, organization: organization) }

      context 'and your teams member' do
        let(:record) do
          create(:user,
                 organization: organization)
            .tap { |u| TeamMember.create! user: u, role: TeamMember::Roles::MEMBER, team: Team.first! }
        end

        it { is_expected.to permit_action(:show) }
      end

      context 'and not your teams member' do
        let(:record) { create(:team_member_user, organization: organization) }

        it { is_expected.to forbid_action(:show) }
      end
    end

    context 'given team member' do
      let!(:user) { create(:team_member_user, organization: organization) }

      context 'and your teams leader' do
        let(:record) do
          create(:user,
                 organization: organization)
            .tap { |u| TeamMember.create! user: u, role: TeamMember::Roles::LEADER, team: Team.first! }
        end

        it { is_expected.to permit_action(:show) }
      end

      context 'and not your teams leader' do
        let(:record) { create(:team_leader_user, organization: organization) }

        it { is_expected.to forbid_action(:show) }
      end
    end
  end

  # describe '#update' do
  #   let(:organization) { create(:organization) }
  #
  #   context 'given regular user' do
  #     let(:user) { create(:user, organization: organization) }
  #     let(:record) { user }
  #
  #     it { is_expected.to permit_action(:update) }
  #   end
  #
  #   context 'given team leader' do
  #     let!(:user) { create(:team_leader_user, organization: organization) }
  #
  #     context 'and your teams member' do
  #       let(:record) do
  #         create(:user,
  #                organization: organization)
  #           .tap { |u| TeamMember.create! user: u, team: Team.first!, role: TeamMember::Roles::MEMBER }
  #       end
  #
  #       it { is_expected.to permit_action(:update) }
  #     end
  #
  #     context 'and not your teams member' do
  #       let(:record) { create(:team_member_user, organization: organization) }
  #
  #       it { is_expected.to forbid_action(:update) }
  #     end
  #   end
  #
  #   context 'given team member' do
  #     let!(:user) { create(:team_member_user, organization: organization) }
  #
  #     context 'and your team leader' do
  #       let(:record) do
  #         create(:user,
  #                organization: organization)
  #           .tap { |u| TeamMember.create! user: u, team: Team.first!, role: TeamMember::Roles::LEADER }
  #       end
  #
  #       it { is_expected.to forbid_action(:update) }
  #     end
  #
  #     context 'and yourself record' do
  #       let(:record) { user }
  #
  #       it { is_expected.to permit_action(:update) }
  #     end
  #   end
  # end
  #
  # describe '#destroy' do
  #   let(:organization) { create(:organization) }
  #
  #   context 'given c-level user and same org user' do
  #     let(:user) { create(:c_level_user, organization: organization) }
  #     let(:record) { create(:user, organization: organization) }
  #
  #     it { is_expected.to permit_action(:destroy) }
  #   end
  #
  #   context 'given c-level user and already deleted org user' do
  #     let(:user) { create(:c_level_user, organization: organization) }
  #     let(:record) { create(:user, organization: organization).tap(&:discard) }
  #
  #     it { is_expected.to forbid_action(:destroy) }
  #   end
  #
  #   context 'given c-level user and another org user' do
  #     let(:user) { create(:c_level_user, organization: organization) }
  #     let(:record) { create(:user) }
  #
  #     it { is_expected.to forbid_action(:destroy) }
  #   end
  #
  #   context 'given team member and same org user' do
  #     let(:user) { create(:team_member_user, organization: organization) }
  #     let(:record) do
  #       create(:user,
  #              organization: organization)
  #         .tap { |u| TeamMember.create! user: u, role: TeamMember::Roles::MEMBER, team: Team.first! }
  #     end
  #
  #     it { is_expected.to forbid_action(:destroy) }
  #   end
  # end
end

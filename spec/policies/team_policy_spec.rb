# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamPolicy do
  subject { described_class.new(user, record) }
  #
  # describe 'index' do
  #   let(:record) { Team }
  #
  #   context 'given random user' do
  #     let(:user) { create(:user) }
  #
  #     it { is_expected.to forbid_action(:index) }
  #   end
  #
  #   context 'given C-Level user' do
  #     let(:user) { create(:user, c_level: true) }
  #
  #     it { is_expected.to permit_action(:index) }
  #   end
  #
  #   context 'given team leaders' do
  #     let(:organization) { create(:organization) }
  #     let(:team) { create(:team, organization: organization) }
  #     let(:user) do
  #       create(:user,
  #              organization: organization)
  #         .tap { |u| TeamMember.create! user: u, team: team, role: TeamMember::Roles::LEADER }
  #     end
  #
  #     it { is_expected.to permit_action(:index) }
  #   end
  # end

  describe 'update' do
    let(:organization) { create(:organization) }

    context 'given regular user' do
      let(:user) { create(:user, organization: organization) }
      let(:record) { create(:team) }

      it { is_expected.to forbid_action(:update) }
    end

    context 'given team leader' do
      let!(:user) { create(:team_leader_user, organization: organization) }

      context 'and your team' do
        let(:record) { Team.first! }

        it { is_expected.to permit_action(:update) }
      end

      context 'and not your team' do
        let(:record) { create(:team) }

        it { is_expected.to forbid_action(:update) }
      end
    end

    context 'given team member' do
      let!(:user) { create(:team_member_user, organization: organization) }

      context 'and your team' do
        let(:record) { Team.first! }

        it { is_expected.to forbid_action(:update) }
      end
    end
  end

  describe 'create_team_member' do
    let(:organization) { create(:organization) }
    let!(:possible_user_to_be_added_as_team_member) { create(:user, name: 'John Brown', organization: organization, leaderbits_sending_enabled: true) }

    context 'given regular user' do
      let(:user) { create(:user, organization: organization) }
      let(:record) { create(:team) }

      it { is_expected.to forbid_action(:create_team_member) }
    end

    context 'given c level user' do
      let!(:user) { create(:c_level_user, organization: organization) }

      context 'and your org team' do
        let(:record) { create(:team, organization: organization) }

        it { is_expected.to permit_action(:create_team_member) }
      end

      context 'and not your team' do
        let(:record) { create(:team) }

        it { is_expected.to forbid_action(:create_team_member) }
      end
    end

    context 'given team leader' do
      let!(:user) { create(:team_leader_user, organization: organization) }

      context 'and your team' do
        let(:record) { Team.first! }

        it { is_expected.to permit_action(:create_team_member) }
      end

      context 'and not your team' do
        let(:record) { create(:team) }

        it { is_expected.to forbid_action(:create_team_member) }
      end
    end

    context 'given team member' do
      let!(:user) { create(:team_member_user, organization: organization) }

      context 'and your team' do
        let(:record) { Team.first! }

        it { is_expected.to forbid_action(:create_team_member) }
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LikedMessageGenerator do
  describe '#return_for_user' do
    subject { described_class.new(votable).return_for_user(current_user) }

    let(:current_user) { create(:system_admin_user, name: 'user4') }

    context 'given reply without likes' do
      let(:votable) { create(:entry_reply) }

      it { is_expected.to eq('') }
    end

    context 'given entry that author liked himself' do
      let(:votable) do
        create(:entry, user: current_user)
      end

      it { is_expected.to eq('') }
    end

    context 'given anonymous entry' do
      let(:votable) do
        create(:entry, visible_to_community_anonymously: true)
      end

      context 'with like from Joel(system admin)' do
        let(:user1) do
          create(:user,
                 organization: organization1,
                 email: Rails.configuration.joel_email,
                 name: 'Joel',
                 system_admin: true)
        end

        let(:organization1) { create(:organization, name: 'LeaderBits') }

        before do
          votable.liked_by user1
        end

        it { is_expected.to eq('Joel liked this entry') }
      end

      context 'with like from LeaderBits employee' do
        let(:user1) do
          create(:user,
                 organization: organization1,
                 email: Rails.configuration.allison_email,
                 name: 'Allison').tap { |u| LeaderbitsEmployee.create! user: u, organization: organization1 }
        end

        let(:organization1) { create(:organization, name: 'LeaderBits') }

        before do
          votable.liked_by user1
        end

        it { is_expected.to eq('Allison liked this entry') }
      end

      context 'with like from mentor' do
        let(:user1) { create(:user, organization: votable.user.organization, name: 'user1') }

        before do
          OrganizationalMentorship.create! mentor_user: user1, mentee_user: votable.user
          votable.liked_by user1
        end

        it { is_expected.to eq('user1 liked this entry') }
      end

      context 'with like from mentee' do
        let(:user1) { create(:user, organization: votable.user.organization, name: 'user1') }

        before do
          OrganizationalMentorship.create! mentor_user: votable.user, mentee_user: user1
          votable.liked_by user1
        end

        it { is_expected.to eq('user1 liked this entry') }
      end

      context 'with likes from random users from other organization and your teammate' do
        let(:user1) { create(:user, name: 'user1') }
        let(:user2) { create(:user, name: 'user2') }

        let(:user3) { create(:user, name: 'user3', organization: votable.user.organization) }

        before do
          votable.liked_by user1
          votable.liked_by user2
          votable.liked_by user3
        end

        it { is_expected.to eq('user3 liked this entry') }
      end
    end
  end
end

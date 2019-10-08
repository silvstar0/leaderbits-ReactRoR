# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LeaderbitPolicy do
  subject { described_class.new(user, leaderbit) }

  describe 'show' do
    context 'given random user' do
      let(:user) { create(:user) }
      let(:leaderbit) { create(:leaderbit) }

      it { is_expected.to forbid_action(:show) }
    end

    context 'given user with leaderbit reference' do
      let(:user) { create(:user) }
      let(:leaderbit) { create(:leaderbit) }

      before do
        # eventually verify both
        if [true, false].sample
          create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit)
        else
          create(:leaderbit_log, user: user, leaderbit: leaderbit, created_at: 2.seconds.ago, updated_at: 2.seconds.ago)
        end
      end

      it { is_expected.to permit_action(:show) }
    end
  end

  describe 'start' do
    context 'given user who just received leaderbit' do
      let(:user) { create(:user) }
      let(:leaderbit) { create(:leaderbit) }

      before do
        create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit)
      end

      it { is_expected.to permit_action(:start) }
    end

    context 'given user who started leaderbit already' do
      let(:user) { create(:user) }
      let(:leaderbit) { create(:leaderbit) }

      before do
        create(:user_sent_scheduled_new_leaderbit, user: user, resource: leaderbit)
        create(:leaderbit_log, user: user, status: LeaderbitLog::Statuses::IN_PROGRESS, leaderbit: leaderbit, created_at: 2.seconds.ago, updated_at: 2.seconds.ago)
      end

      it { is_expected.to forbid_action(:start) }
    end
  end
end

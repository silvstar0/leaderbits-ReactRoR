# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SettingsHelper, type: :helper do
  describe '#points_as_graph_data(current_user)' do
    subject { helper.points_over_time(user) }

    let(:leaderbit) { create(:leaderbit) }
    let(:user) { create(:user) }

    context 'given user without points' do
      it { is_expected.to be_empty }
    end

    context 'given same date points' do
      before do
        create(:point, value: 10, created_at: Date.today, user: user, pointable: leaderbit)
        create(:point, value: 15, created_at: Date.today, user: user, pointable: leaderbit)
      end

      it { is_expected.to eq(Date.today.noon.to_i => 25) }
    end

    context 'given different date points' do
      before do
        create(:point, value: 10, created_at: Date.today, user: user, pointable: leaderbit)
        create(:point, value: 15, created_at: Date.today, user: user, pointable: leaderbit)
        create(:point, value: 30, created_at: Date.tomorrow, user: user, pointable: leaderbit)
      end

      it { is_expected.to eq(Date.today.noon.to_i => 25, Date.tomorrow.noon.to_i => 55) }
    end
  end
end

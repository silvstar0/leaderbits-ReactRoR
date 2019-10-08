# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HourlySendingOfBoomerang do
  let(:tz_name) { 'London' }

  describe '.call' do
    before do
      Timecop.travel time_now_in_user_tz
    end

    let!(:user) {
      create(:user,
             hour_of_day_to_send: 9,
             time_zone: tz_name) # different than Rails config time zone(Central Time)
    }
    let!(:entry) { create(:entry, user: user) }

    context 'in couple days option' do
      context 'given the matching moment for user' do
        let(:time_now_in_user_tz) { friday_time hour: 9, tz_name: tz_name }
        let!(:boomerang_leaderbit) do
          BoomerangLeaderbit.create! leaderbit: entry.leaderbit,
                                     user: user,
                                     type: BoomerangLeaderbit::Types::COUPLE_DAYS,
                                     created_at: 2.days.until(time_now_in_user_tz)
        end

        it 'sends leaderbit email and create UserSentScheduledLeaderbit record' do
          expect { described_class.call }.to have_enqueued_job(ActionMailer::Parameterized::DeliveryJob)
                                               .with("LeaderbitMailer", "boomerang", "deliver_now", leaderbit: entry.leaderbit, user: user)
        end
      end

      context 'given the wrong moment for user' do
        let(:time_now_in_user_tz) { friday_time hour: 8, tz_name: tz_name }
        let!(:boomerang_leaderbit) do
          BoomerangLeaderbit.create! leaderbit: entry.leaderbit,
                                     user: user,
                                     type: BoomerangLeaderbit::Types::COUPLE_DAYS,
                                     created_at: 2.days.until(time_now_in_user_tz)
        end

        it 'does nothing' do
          expect { described_class.call }.not_to have_enqueued_job(ActionMailer::Parameterized::DeliveryJob)
        end
      end
    end

    context 'in two weeks option' do
      context 'given the matching moment for user' do
        let(:time_now_in_user_tz) { friday_time hour: 9, tz_name: tz_name }
        let!(:boomerang_leaderbit) do
          BoomerangLeaderbit.create! leaderbit: entry.leaderbit,
                                     user: user,
                                     type: BoomerangLeaderbit::Types::TWO_WEEKS,
                                     created_at: 14.days.until(time_now_in_user_tz)
        end

        it 'sends leaderbit email and create UserSentScheduledLeaderbit record' do
          expect { described_class.call }.to have_enqueued_job(ActionMailer::Parameterized::DeliveryJob)
                                               .with("LeaderbitMailer", "boomerang", "deliver_now", leaderbit: entry.leaderbit, user: user)
        end
      end
    end
  end
end

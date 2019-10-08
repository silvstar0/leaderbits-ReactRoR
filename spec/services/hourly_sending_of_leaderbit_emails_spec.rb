# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HourlySendingOfLeaderbitEmails do
  let(:tz_name) { 'London' }
  let(:organization) { create(:organization, active_since: 3.weeks.ago) }

  let(:schedule) { create(:schedule) }
  let(:leaderbit) do
    create(:active_leaderbit, name: 'Leaderbit 1').tap do |leaderbit|
      leaderbit_schedule = schedule.leaderbit_schedules.create! leaderbit: leaderbit
      leaderbit_schedule.update_column :position, 0
      leaderbit
    end
  end

  describe '.call' do
    before do
      Timecop.travel time_now_in_user_tz
    end

    context 'when user received leaderbit recently and switch hour/day of week to send' do
      let(:time_now_in_user_tz) { tuesday_time hour: 9, tz_name: tz_name }

      let!(:user) {
        create(:user,
               organization: organization,
               schedule: schedule,
               time_zone: tz_name,
               day_of_week_to_send: 'Tuesday',
               hour_of_day_to_send: 9 ) # different than Rails config time zone(Central Time)
      }

      it 'does not schedule leaderbits more often than once a week' do
        Timecop.freeze(2.days.until(time_now_in_user_tz)) do
          create :user_sent_scheduled_new_leaderbit,
                 user: user,
                 resource: create(:active_leaderbit)
        end

        allow(instance_double(User)).to receive(:next_leaderbit_to_send).and_return([leaderbit])

        expect { described_class.call }.not_to have_enqueued_job(ScheduledNewLeaderbitMailerJob)
      end
    end

    context 'when regular recipient' do
      let(:organization) {
        create(:organization,
               hour_of_day_to_send: 9,
               active_since: 3.weeks.ago,
               day_of_week_to_send: 'Tuesday')
      }
      let!(:user) {
        create(:user,
               email: 'this@guy.com',
               schedule: schedule,
               organization: organization,
               hour_of_day_to_send: organization.hour_of_day_to_send,
               day_of_week_to_send: organization.day_of_week_to_send,
               time_zone: tz_name) # different than Rails config time zone(Central Time)
      }

      let(:time_now_in_user_tz) { tuesday_time hour: 9, tz_name: tz_name }

      it 'sends leaderbit email and create UserSentScheduledLeaderbit record' do
        allow(instance_double(User)).to receive(:upcoming_active_leaderbits_from_schedule).and_return([leaderbit])

        expect { described_class.call }.to have_enqueued_job(ScheduledNewLeaderbitMailerJob)
      end

      context 'when user is currently in vacation mode' do
        let(:organization) {
          create(:organization,
                 hour_of_day_to_send: 9,
                 active_since: 3.weeks.ago,
                 day_of_week_to_send: 'Tuesday')
        }
        let!(:user) {
          create(:user,
                 email: 'this@guy.com',
                 day_of_week_to_send: organization.day_of_week_to_send,
                 schedule: schedule,
                 organization: organization,
                 hour_of_day_to_send: organization.hour_of_day_to_send,
                 time_zone: tz_name) # different than Rails config time zone(Central Time)
        }

        let(:time_now_in_user_tz) { tuesday_time hour: 9, tz_name: tz_name }

        it 'does not send leaderbit' do
          vm = build(:vacation_mode, user: user, starts_at: 2.days.ago.to_date, ends_at: 2.days.from_now)
          vm.save validate: false

          expect { described_class.call }.not_to have_enqueued_job(ScheduledNewLeaderbitMailerJob)
          #allow(instance_double(User)).to receive(:upcoming_leaderbits_from_schedule_and_preemptive_queue).and_return([leaderbit])

          #expect { described_class.call }.to have_enqueued_job(ScheduledNewLeaderbitMailerJob)
        end
      end

      context 'when vacation mode is over for user' do
        let(:organization) {
          create(:organization,
                 hour_of_day_to_send: 9,
                 active_since: 3.weeks.ago,
                 day_of_week_to_send: 'Tuesday')
        }
        let!(:user) {
          create(:user,
                 email: 'this@guy.com',
                 day_of_week_to_send: organization.day_of_week_to_send,
                 schedule: schedule,
                 organization: organization,
                 hour_of_day_to_send: organization.hour_of_day_to_send,
                 time_zone: tz_name) # different than Rails config time zone(Central Time)
        }

        let(:time_now_in_user_tz) { tuesday_time hour: 9, tz_name: tz_name }

        it 'sends leaderbit email and create UserSentScheduledLeaderbit record' do
          vm = build(:vacation_mode, user: user, starts_at: 2.days.ago, ends_at: 2.seconds.ago)
          vm.save validate: false

          allow(instance_double(User)).to receive(:next_leaderbit_to_send).and_return([leaderbit])

          expect { described_class.call }.to have_enqueued_job(ScheduledNewLeaderbitMailerJob)
        end
      end
    end
  end
end

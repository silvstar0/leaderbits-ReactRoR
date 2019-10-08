# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LeaderbitSendingAnomalyDetection do
  describe '.call' do
    context "when you run it during any hour's 30..40 minute interval" do
      context 'given no missing leadebits to send' do
        let(:mid_hour_time) { Chronic.parse('this tuesday 02:32') }

        it 'does not fail, does not call Rollbar' do
          create(:user, created_at: 2.weeks.until(mid_hour_time), organization: create(:organization, active_since: 3.days.ago))
          #TODO figure out why spec is not always stable and randomly fails with:
          #(Rollbar).warning("Actual number of leaderbits to be sent is less than planned")
          # expected: 0 times with any arguments
          # received: 1 time with arguments: ("Actual number of leaderbits to be sent is less than planned")
          expect(Rollbar).not_to receive(:warning)

          #NOTE: sometimes it fails on CI, try to re-run it, figure it out and make stable
          Timecop.freeze(mid_hour_time) {
            described_class.call
          }
        end
      end

      context 'given a regular leader with missing leadebit to send' do
        let(:tz_name) { 'London' }
        let(:time_now_in_user_tz) { tuesday_time hour: 9, minute: 32, tz_name: tz_name }

        let(:organization) { create(:organization, active_since: 3.weeks.until(time_now_in_user_tz)) }

        let!(:user) {
          create(:user,
                 schedule: schedule,
                 organization: organization,
                 time_zone: tz_name,
                 created_at: 2.weeks.until(time_now_in_user_tz),
                 day_of_week_to_send: 'Tuesday',
                 hour_of_day_to_send: 9 ) # different than Rails config time zone(Central Time)
        }
        let(:schedule) { create(:schedule) }
        let(:leaderbit) do
          create(:active_leaderbit).tap { |leaderbit| schedule.leaderbit_schedules.create! leaderbit: leaderbit }
        end

        example do
          expect(Rollbar).to receive(:warning)

          Timecop.freeze(time_now_in_user_tz) {
            described_class.call
          }
        end
      end

      context 'given a mentee who just accepted his invitation to become a mentee' do
        let(:tz_name) { 'London' }
        let(:time_now_in_user_tz) { tuesday_time hour: 9, minute: 32, tz_name: tz_name }

        let(:organization) { create(:organization, active_since: 3.weeks.until(time_now_in_user_tz)) }

        let!(:user) {
          create(:user,
                 schedule: schedule,
                 organization: organization,
                 created_at: 2.weeks.until(time_now_in_user_tz),
                 time_zone: tz_name,
                 day_of_week_to_send: 'Tuesday',
                 hour_of_day_to_send: 9 ) # different than Rails config time zone(Central Time)
        }
        let(:schedule) { create(:schedule) }
        let(:leaderbit) do
          create(:active_leaderbit).tap { |leaderbit| schedule.leaderbit_schedules.create! leaderbit: leaderbit }
        end

        it 'is temporary excluded from sending plan checking' do
          expect(Rollbar).not_to receive(:warning)

          Timecop.freeze(time_now_in_user_tz) {
            OrganizationalMentorship
              .create!(mentor_user: create(:user), mentee_user: user, accepted_at: 1.hours.ago)

            described_class.call
          }
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminHelper, type: :helper do
  describe '#user_accessible_leaderbits_for_preemptive_queue' do
    let!(:schedule) { Schedule.create! name: Schedule::GLOBAL_NAME }
    let!(:user) { create(:user, schedule: schedule) }
    let!(:leaderbit1) { create(:leaderbit, active: true) }
    let!(:leaderbit2) { create(:leaderbit, active: true) }

    example do
      schedule.leaderbit_schedules.create! leaderbit: leaderbit1
      schedule.leaderbit_schedules.create! leaderbit: leaderbit2

      create(:preemptive_leaderbit, user: user, leaderbit: leaderbit2)

      expect(helper.user_accessible_leaderbits_for_preemptive_queue(user)).to contain_exactly(leaderbit1)
    end
  end
end

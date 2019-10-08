# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UpdateLeaderbit do
  context 'given leaderbit that does not belong to any schedule' do
    example do
      leaderbit = create(:leaderbit)
      schedule = create(:schedule)

      params = { "id" => leaderbit.id, "leaderbit" => { "name" => "Challenge: All about the people.", "desc" => "Today", "url" => "https://player.vimeo.com/video/282953047", "body" => "Hello my friends!", "active" => "1", "schedule" => { schedule.id => "on" } } }.with_indifferent_access
      transaction = described_class.new
      transaction.call(params) do |result|
        expect(result.failure).to be_nil

        result.success do
          expect(leaderbit.reload.name). to eq("Challenge: All about the people.")

          expect(schedule.leaderbit_schedules.pluck(:leaderbit_id)).to contain_exactly(leaderbit.id)
        end
      end
    end
  end

  context 'given leaderbit that does not belong to any schedule' do
    example do
      leaderbit = create(:leaderbit)

      schedule1 = create(:schedule)
      schedule2 = create(:schedule)
      schedule3 = create(:schedule)

      leaderbit_schedule = schedule1.leaderbit_schedules.create! leaderbit: leaderbit
      leaderbit_schedule.update_column :position, 0

      leaderbit_schedule = schedule2.leaderbit_schedules.create! leaderbit: leaderbit
      leaderbit_schedule.update_column :position, 1

      params = { "id" => leaderbit.id, "leaderbit" => { "name" => "Challenge: All about the people.", "desc" => "Today", "url" => "https://player.vimeo.com/video/282953047", "body" => "Hello my friends!", "active" => "1", "schedule" => { schedule1.id => "on", schedule3.id => "on" } } }.with_indifferent_access
      transaction = described_class.new
      transaction.call(params) do |result|
        expect(result.failure).to be_nil

        result.success do
          expect(leaderbit.reload.name). to eq("Challenge: All about the people.")

          expect(leaderbit.leaderbit_schedules.pluck(:schedule_id)).to contain_exactly(schedule1.id, schedule3.id)
        end
      end
    end
  end
end

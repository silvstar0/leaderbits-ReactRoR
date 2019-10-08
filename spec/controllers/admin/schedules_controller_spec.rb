# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SchedulesController, type: :controller do
  describe "POST #sort" do
    login_user

    context "given global(non-user specific) leaderbits" do
      example 'sorts leaderbits', login_factory: :system_admin_user do
        schedule = create(:schedule)
        create_list(:leaderbit, 3)

        valid_attribute = Leaderbit.pluck(:id).shuffle

        post :sort, params: { id: schedule.id, leaderbit: valid_attribute }, xhr: true

        actual = schedule
                   .leaderbit_schedules
                   .includes(:leaderbit)
                   .order(position: :asc)
                   .collect(&:leaderbit_id)

        expect(actual).to eq(valid_attribute)
      end
    end
  end

  describe "POST #add_leaderbit" do
    login_user

    example '', login_factory: :system_admin_user do
      schedule = create(:schedule)
      leaderbit = create(:leaderbit)

      expect {
        post :add_leaderbit, params: { id: schedule.id, leaderbit: { id: leaderbit.id } }, xhr: true
      }.to change { schedule.leaderbit_schedules.where(leaderbit: leaderbit).count }.to(1)
    end
  end

  describe "POST #remove_leaderbit" do
    login_user

    example "", login_factory: :system_admin_user do
      schedule = create(:schedule)

      leaderbit1 = create(:leaderbit)
      leaderbit2 = create(:leaderbit)

      schedule.leaderbit_schedules.create leaderbit: leaderbit1
      schedule.leaderbit_schedules.create leaderbit: leaderbit2

      expect {
        post :remove_leaderbit, params: { leaderbit_id: leaderbit1.id, id: schedule.id }
      }.to change { schedule.leaderbit_schedules.count }.from(2).to(1)

      expect(Leaderbit.count).to eq(2)
    end
  end

  describe "POST #clone" do
    login_user

    example '', login_factory: :system_admin_user do
      schedule = Schedule.create! name: Schedule::GLOBAL_NAME

      leaderbit1 = create(:leaderbit)
      leaderbit2 = create(:leaderbit)

      schedule.leaderbit_schedules.create! leaderbit: leaderbit1
      schedule.leaderbit_schedules.create! leaderbit: leaderbit2

      expect {
        post :clone, params: { id: schedule.id }, xhr: true
      }.to change(Schedule, :count).by(1)

      new_schedule = Schedule.last
      expect(new_schedule.name).to eq("Global Copy #1")

      expect(schedule.leaderbit_schedules.pluck(:leaderbit_id, :position)).to eq(new_schedule.leaderbit_schedules.pluck(:leaderbit_id, :position))

      expect {
        post :clone, params: { id: schedule.id }, xhr: true
      }.to change(Schedule, :count).by(1)

      expect(Schedule.last.name).to eq("Global Copy #2")
    end
  end
end

# frozen_string_literal: true

module Admin
  class CreateLeaderbit
    include Dry::Transaction

    step :validate
    #TODO wrap all the following steps in db transaction
    step :create_leaderbit
    step :create_leaderbit_tags
    step :assign_leaderbit_to_schedules
    step :notify_joel_if_leaderbit_is_inactive

    private

    def validate(input)
      leaderbit = Leaderbit.new
      leaderbit.attributes = input.fetch(:leaderbit).without('schedule', 'tags_csv')
      leaderbit.valid? ? Success(input) : Failure(leaderbit)
    end

    def create_leaderbit(input)
      leaderbit = Leaderbit.new
      leaderbit.attributes = input.fetch(:leaderbit).without('schedule', 'tags_csv')

      leaderbit.save!

      Success(input: input, leaderbit: leaderbit)
    end

    def create_leaderbit_tags(result)
      input = result.fetch(:input)
      leaderbit = result.fetch(:leaderbit)

      tags_csv = input.dig(:leaderbit, :tags_csv)
      if tags_csv.present?
        tags_csv.split(",").each do |label|
          leaderbit.tags.create! label: label
        end
      end

      Success(result)
    end

    def assign_leaderbit_to_schedules(result)
      input = result.fetch(:input)
      leaderbit = result.fetch(:leaderbit)

      schedule_param = input.dig(:leaderbit, :schedule)

      if schedule_param.present?
        leaderbit_belong_to_schedule_ids = schedule_param
                                             .keys
                                             .map(&:to_s)
                                             .map(&:to_i)

        leaderbit_belong_to_schedule_ids.each do |schedule_id|
          LeaderbitSchedule.create! leaderbit_id: leaderbit.id, schedule_id: schedule_id
        end
      end
      Success(leaderbit)
    end

    def notify_joel_if_leaderbit_is_inactive(leaderbit, current_user:)
      unless current_user.can_make_leaderbit_active?
        AdminMailer
          .with(leaderbit: leaderbit, created_by: current_user)
          .notify_joel_about_new_inactive_leaderbit
          .deliver_now
      end

      Success(leaderbit)
    end
  end
end

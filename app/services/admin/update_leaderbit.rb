# frozen_string_literal: true

module Admin
  class UpdateLeaderbit
    include Dry::Transaction

    step :validate
    step :update

    private

    def validate(input)
      leaderbit = Leaderbit.find input.fetch(:id)

      leaderbit.attributes = input.fetch(:leaderbit).without('schedule', 'tags_csv')
      #TODO-low Success(leaderbit) instead?
      leaderbit.valid? ? Success(input) : Failure(leaderbit)
    end

    def update(input)
      leaderbit = Leaderbit.find input.fetch(:id)
      leaderbit.attributes = input.fetch(:leaderbit).without('schedule', 'tags_csv')

      leaderbit.save!

      tags_csv = input.dig(:leaderbit, :tags_csv)
      labels = tags_csv.to_s.split(",")
      leaderbit.tags.where.not(label: labels).delete_all
      labels.each { |label| leaderbit.tags.find_or_create_by! label: label }

      schedule_ids = Array(input
                             .dig(:leaderbit, :schedule)
                             &.keys)
                       .map(&:to_s)
                       .map(&:to_i)

      already_present_in_schedule_ids = LeaderbitSchedule
                                          .where(leaderbit: leaderbit)
                                          .pluck(:schedule_id)

      schedule_ids_to_remove = already_present_in_schedule_ids - schedule_ids
      LeaderbitSchedule.where(leaderbit_id: leaderbit.id, schedule_id: schedule_ids_to_remove).destroy_all

      schedule_ids_to_add = schedule_ids - already_present_in_schedule_ids
      schedule_ids_to_add.each do |schedule_id|
        LeaderbitSchedule.create! leaderbit_id: leaderbit.id, schedule_id: schedule_id
      end

      Success(leaderbit)
    end
  end
end

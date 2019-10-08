# frozen_string_literal: true

require_dependency Rails.root.join('app/services/admin/concerns/acts_as_user_creatable')

module Admin
  class UpdateUser
    include Dry::Transaction
    include ::Admin::ActsAsUserCreateable

    step :validate
    step :update

    private

    def validate(input)
      user = User.find_by_uuid input.fetch(:id)

      user.attributes = user_attributes input

      user = before_validate(user, input)

      return Success(input: input, user: user) if user.valid?

      Failure(user)
    end

    def update(input:, user:)
      ActiveRecord::Base.transaction do
        user.save!

        if input[:daterange_from].present? && input[:daterange_to].present?

          Time.use_zone(user.time_zone) do
            starts_at = Time.zone.parse(input[:daterange_from]).beginning_of_day
            ends_at = Time.zone.parse(input[:daterange_to]).end_of_day

            VacationMode.create! user: user,
                                 starts_at: starts_at,
                                 reason: input[:vacation_mode_reason],
                                 ends_at: ends_at
          end
        end

        after_save user, input
      end

      Success(user)
    end
  end
end

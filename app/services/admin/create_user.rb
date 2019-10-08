# frozen_string_literal: true

require_dependency Rails.root.join('app/services/admin/concerns/acts_as_user_creatable')

module Admin
  class CreateUser
    include Dry::Transaction
    include ::Admin::ActsAsUserCreateable

    step :validate
    step :create

    private

    def validate(input)
      user = User.new
      user.attributes = user_attributes input

      user = before_validate(user, input)

      return Success(input: input, user: user) if user.valid?

      Failure(user)
    end

    def create(input:, user:)
      ActiveRecord::Base.transaction do
        user.save!

        after_save user, input
      end

      Success(user)
    end
  end
end

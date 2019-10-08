# frozen_string_literal: true

module Admin
  class UserNotesController < BaseController
    before_action :set_user
    skip_before_action :verify_authenticity_token, only: %i[update]

    def update
      @user.admin_notes = params.fetch(:content)
      @user.admin_notes_updated_at = Time.now

      @user.save validate: false

      head :ok
    end

    private

    def set_user
      value = params.fetch(:user_id)
      @user = User.find_by_uuid(value) || User.find(value)
    end
  end
end

# frozen_string_literal: true

module Admin
  class VacationModesController < BaseController
    def destroy
      vacation_mode = VacationMode.find(params[:id])
      vacation_mode.destroy!

      redirect_to edit_admin_user_path(vacation_mode.user), notice: 'Vacation mode successfully destroyed.'
    end
  end
end

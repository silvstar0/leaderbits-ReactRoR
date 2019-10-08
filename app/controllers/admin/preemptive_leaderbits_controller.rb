# frozen_string_literal: true

module Admin
  class PreemptiveLeaderbitsController < BaseController
    protect_from_forgery except: [:sort]

    def create
      authorize [:admin, PreemptiveLeaderbit]
      user = User.find_by_uuid params[:user_id]

      leaderbit = Leaderbit.find params.dig(:leaderbit, :id)

      user.preemptive_leaderbits.create! leaderbit: leaderbit, added_by_user: current_user

      redirect_back(fallback_location: admin_dashboard_path, notice: "#{leaderbit.name} has just been added to the Instant Queue for #{user.name}")
    end

    def destroy_by_leaderbit_id
      authorize [:admin, PreemptiveLeaderbit]

      user = User.find_by_uuid params.fetch(:user_id)
      leaderbit_id = params.fetch(:leaderbit_id)
      user.preemptive_leaderbits.where(leaderbit_id: leaderbit_id).delete_all

      redirect_back(fallback_location: admin_dashboard_path, notice: "Instant Queue LeaderBit #{Leaderbit.find(leaderbit_id).name} has just been deleted")
    end

    def sort
      user = User.find_by_uuid!(params[:id])
      authorize [:admin, PreemptiveLeaderbit]

      ActiveRecord::Base.transaction do
        PreemptiveLeaderbit.where(user: user).delete_all

        params[:leaderbit].each.with_index(1) do |id, index|
          leaderbit = Leaderbit.find(id)
          preemptive_leaderbit = user.preemptive_leaderbits.create! leaderbit: leaderbit, added_by_user: current_user
          preemptive_leaderbit.update_column :position, index
        end
      end

      render js: "window.location.reload()"
    end
  end
end

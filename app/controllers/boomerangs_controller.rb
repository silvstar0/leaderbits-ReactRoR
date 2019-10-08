# frozen_string_literal: true

class BoomerangsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[create]

  def create
    leaderbit = Leaderbit.find params.fetch(:leaderbit_id)

    bl = BoomerangLeaderbit.find_or_initialize_by(leaderbit: leaderbit, user: current_user)
    bl.type = params[:boomerang][:type]
    bl.save!

    respond_to do |format|
      format.js
    end
  end
end

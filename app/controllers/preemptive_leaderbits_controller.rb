# frozen_string_literal: true

class PreemptiveLeaderbitsController < ApplicationController
  #TODO why is it not covered by Simplecov? We clearly have capybara spec for that
  def create
    user = User.find_by_uuid params[:user_id]
    authorize user, :manage_preemptive_leaderbits_for?

    leaderbit = Leaderbit.find params.dig(:leaderbit, :id)

    user.preemptive_leaderbits.create! leaderbit: leaderbit, added_by_user: current_user

    redirect_back(fallback_location: user_path(user.uuid), notice: "#{leaderbit.name} has just been added to the Instant Queue for #{user.name}")
  end
end

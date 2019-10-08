# frozen_string_literal: true

class TeamsController < ApplicationController
  #before_action :set_organization, only: %i[index new edit update create]
  before_action :set_team, only: %i[edit update]

  def new
    @team = Team.new
    authorize @team #@organization, :create_team?
  end

  def create
    @team = Team.new(team_params)
    @team.organization = current_user.organization
    authorize @team #@organization, :create_team?
    if @team.save
      redirect_to company_path
    else
      render 'new'
    end
  end

  def edit
    authorize @team
  end

  def update
    @team = Team.find(params[:id])
    authorize @team

    @team.attributes = team_params
    if @team.save
      unobtrusive_flash.regular type: :notice, message: "Team successfully updated."
      redirect_to company_path
    else
      render 'edit'
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end

# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :set_team, only: %i[edit update]

  def show
    @teams = if current_user.c_level?
               current_user.organization.teams.order(name: :asc)
             else
               TeamMember.where(user: current_user).collect(&:team).uniq
             end

    if params[:new].present?
      @team = Team.find(params[:team_id])
      #TODO add authorize
      @team_member = TeamMember.new
      @team_member.role = TeamMember::Roles::MEMBER
      @team_member.user = User.new

    elsif params[:edit].present?
      @team_member = TeamMember
                       .joins(:user)
                       .where('team_members.id = ?', params[:edit])
                       .where('users.organization_id = ?', current_user.organization_id)
                       .first!
      @team = @team_member.team
    end
  end
end

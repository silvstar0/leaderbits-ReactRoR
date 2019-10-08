# frozen_string_literal: true

class TeamMembersController < ApplicationController
  before_action :authenticate_user!

  before_action :set_team, only: %i[create]

  def create
    name = params.dig(:team_member, :user_attributes, :name)
    email = params.dig(:team_member, :user_attributes, :email)

    # in case role is disabled/readonly it is sent as nil so use default instead
    # that is leader creating a new team member
    role = params.dig(:team_member, :role) || TeamMember::Roles::MEMBER

    user = current_user.organization.users.where(email: email).first!

    TeamMember.where(user: user, team: @team).delete_all
    TeamMember.create! user: user, team: @team, role: role

    unobtrusive_flash.regular type: :notice, message: "#{name} has been added to the team."
    redirect_to controller: params[:controller_name], action: params[:action_name]
  end

  def update
    team_member = TeamMember
                    .joins(:user)
                    .where('users.organization_id = ?', current_user.organization_id)
                    .where('team_members.id = ?', params[:id])
                    .first!

    # in case role is disabled/readonly it is sent as nil
    new_role = params.dig(:team_member, :role)
    team_member.role = new_role if new_role.present?

    #TODO-High add validation
    team_member.save!

    unobtrusive_flash.regular type: :notice, message: "#{team_member.user.name} has been added updated."
    redirect_to controller: params[:controller_name], action: params[:action_name]
  end

  def destroy
    team_member = TeamMember
                    .joins(:user)
                    .where('users.organization_id = ?', current_user.organization_id)
                    .where('team_members.id = ?', params[:id])
                    .first!

    team_member.destroy!

    unobtrusive_flash.regular type: :notice, message: "#{team_member.user.name} is no longer part of the team."
    redirect_to controller: params[:controller_name], action: params[:action_name]
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  end

  def user_params
    params.require(:team_member).require(:user_attributes).permit(:name,
                                                                  :email,
                                                                  :time_zone,
                                                                  :hour_of_day_to_send,
                                                                  :day_of_week_to_send)
  end
end

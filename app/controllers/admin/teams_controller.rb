# frozen_string_literal: true

module Admin
  class TeamsController < BaseController
    add_breadcrumb 'Admin'
    add_breadcrumb 'Teams', %i[admin teams]

    def index
      #TODO add authorize?
      if params[:organization_id].present?
        @organization = Organization.find params[:organization_id]
        @teams = @organization.teams.order(created_at: :desc)
      else
        @teams = Team.all.order(created_at: :desc)
      end
    end

    def show
      #TODO add authorize?
      @team = Team.find(params[:id])
    end
  end
end

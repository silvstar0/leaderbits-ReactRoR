# frozen_string_literal: true

class AchievementsController < ApplicationController
  def show
    _achievement, achievement_id = params[:type].split('|')

    respond_to do |format|
      format.js do
        #TODO why do we need these 2 types of checks? Need some clarification
        template_name = case achievement_id.to_s
                        when Rails.configuration.achievements.first_completed_challenge__on_leaderbits_show
                          :first_completed_challenge__on_leaderbits_show
                        when Rails.configuration.achievements.first_completed_challenge__on_dashboard
                          :first_completed_challenge__on_dashboard
                        else
                          raise "unknown achievement type #{params[:type]}"
                        end

        render template_name
      end
    end
  end
end

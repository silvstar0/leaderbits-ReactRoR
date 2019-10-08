# frozen_string_literal: true

class SettingsController < ApplicationController
  before_action :set_setting, only: %i[show edit update destroy]
  before_action :authenticate_user!

  layout 'settings'

  def strength_levels
    if params[:preview_user_id].present?
      @preview_user = User.find(params[:preview_user_id])
      @strength_levels = StrengthLevelsFormObject.new @preview_user.strength_levels

      authorize @preview_user

      return
    end

    authorize current_user
    @strength_levels = StrengthLevelsFormObject.new current_user.strength_levels

    if request.patch?
      params.fetch(StrengthLevelsFormObject.param_key).each do |symbol_name, value|
        level = current_user.strength_levels.find_or_initialize_by symbol_name: symbol_name

        level.value = value
        level.save! if level.changed?

        unobtrusive_flash.regular type: :notice, message: "Strength Levels successfully updated"
      end
      redirect_to action: __method__
    end
  end

  def community
    authorize current_user
  end

  def analytics
    authorize current_user
  end
end

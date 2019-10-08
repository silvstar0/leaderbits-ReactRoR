# frozen_string_literal: true

class VacationModesController < ApplicationController
  before_action :authenticate_user!

  def create
    #NOTE: Simplecov disabled because those specs are skipped on CI
    #:nocov:
    if params[:daterange_from].blank? || params[:daterange_to].blank?
      raise request.inspect
    end

    Time.use_zone(current_user.time_zone) do
      starts_at = Time.zone.parse(params[:daterange_from]).beginning_of_day
      ends_at = Time.zone.parse(params[:daterange_to]).end_of_day

      vm = VacationMode.new user: current_user,
                            starts_at: starts_at,
                            reason: params.dig(:vacation_mode, :reason),
                            ends_at: ends_at
      if vm.valid?
        vm.save!
        unobtrusive_flash.regular type: :notice, message: "Vacation mode successfully updated"
      else
        error = vm.errors.full_messages.join(". ")
        unobtrusive_flash.regular type: :error, message: error
      end
      redirect_to edit_user_path(current_user.uuid)
    end
    #:nocov:
  end

  def update
    #NOTE: Simplecov disabled because those specs are skipped on CI
    #:nocov:
    vacation_mode = VacationMode.find params.fetch :id
    authorize vacation_mode

    if params[:daterange_from].blank? || params[:daterange_to].blank?
      raise request.inspect
    end

    Time.use_zone(current_user.time_zone) do
      starts_at = Time.zone.parse(params[:daterange_from]).beginning_of_day
      ends_at = Time.zone.parse(params[:daterange_to]).end_of_day

      vacation_mode.starts_at = starts_at
      vacation_mode.reason = params.dig(:vacation_mode, :reason)
      vacation_mode.ends_at = ends_at
      #vacation_mode.save!
      if vacation_mode.valid?
        vacation_mode.save!
        unobtrusive_flash.regular type: :notice, message: "Vacation mode successfully updated"
      else
        error = vacation_mode.errors.full_messages.join(". ")
        unobtrusive_flash.regular type: :error, message: error
      end
      redirect_to edit_user_path(current_user.uuid)
    end
    #:nocov:
  end

  def destroy
    vacation_mode = VacationMode.find(params[:id])

    authorize vacation_mode

    vacation_mode.destroy!

    unobtrusive_flash.regular type: :notice, message: 'Vacation mode successfully deleted'
    redirect_to edit_user_path(current_user.uuid)
  end
end

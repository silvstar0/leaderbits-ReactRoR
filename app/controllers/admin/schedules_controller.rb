# frozen_string_literal: true

module Admin
  class SchedulesController < BaseController
    protect_from_forgery except: [:sort]

    add_breadcrumb 'Admin'
    add_breadcrumb 'Schedules', %i[admin schedules]

    before_action :set_schedule, only: %i[show edit update destroy]

    def index
      @schedules = Schedule.order(order_by[:value]).paginate(page: params[:page], per_page: 30)
      authorize [:admin, Schedule]
    end

    def show
      @leaderbits = @schedule
                      .leaderbit_schedules
                      .joins(:leaderbit)
                      .includes(:leaderbit)
                      .order(position: :asc)
                      .collect(&:leaderbit)
    end

    def new
      @schedule = Schedule.new
      authorize [:admin, @schedule]
    end

    def create
      @schedule = Schedule.new(schedule_params)
      authorize [:admin, @schedule]

      if @schedule.save
        redirect_to [:admin, @schedule], notice: 'Schedule successfully created.'
      else
        render :new, alert: 'Schedule could not be created.'
      end
    end

    def edit
      authorize [:admin, @schedule]

      add_breadcrumb @schedule.name, admin_schedule_path(@schedule.to_param)
    end

    def update
      authorize [:admin, @schedule]

      add_breadcrumb @schedule.name, admin_schedule_path(@schedule.to_param)

      if @schedule.update(schedule_params)
        redirect_to [:admin, @schedule], notice: 'Schedule successfully updated.'
      else
        render :edit, alert: 'Schedule could not be updated.'
      end
    end

    def destroy
      authorize [:admin, @schedule]

      if @schedule.destroy
        redirect_to %i[admin schedules], notice: 'Schedule successfully destroyed.'
      else
        redirect_to [:admin, @schedule], notice: 'Schedule could not be destroyed.'
      end
    end

    def sort
      schedule = Schedule.find(params[:id])
      authorize [:admin, schedule]

      ActiveRecord::Base.transaction do
        LeaderbitSchedule.where(schedule: schedule).delete_all

        params[:leaderbit].each.with_index(1) do |id, index|
          leaderbit = Leaderbit.find(id)
          leaderbit_schedule = schedule.leaderbit_schedules.create! leaderbit: leaderbit
          leaderbit_schedule.update_column :position, index
        end
      end

      render js: "window.location.reload()"
    end

    def add_leaderbit
      schedule = Schedule.find(params[:id])
      authorize [:admin, schedule]

      leaderbit = Leaderbit.find params.dig(:leaderbit, :id)

      schedule.leaderbit_schedules.create! leaderbit: leaderbit
      render js: "window.location.reload()"
      nil
    end

    def remove_leaderbit
      schedule = Schedule.find params[:id]

      authorize [:admin, schedule]

      leaderbit = Leaderbit.find params[:leaderbit_id]

      schedule.leaderbit_schedules.where(leaderbit: leaderbit).first&.destroy
      render js: "window.location.reload()"
    end

    def clone
      schedule = Schedule.find(params[:id])
      authorize [:admin, schedule]

      new_schedule = schedule.deep_clone(include: :leaderbit_schedules, except: :name) do |original, kopy|
        kopy.cloned_from_id = original.id if kopy.respond_to?(:cloned_from_id)
      end
      new_schedule.name = "#{schedule.name} Copy ##{Schedule.where(cloned_from_id: schedule.id).count + 1}"

      new_schedule.save!

      # TODO-low: replace vanilla remote:true link_to with form and redirect to :show page instead

      render js: "window.location.reload()"
    end

    private

    def set_schedule
      @schedule = Schedule.find(params[:id])
    end

    def schedule_params
      params.require(:schedule).permit(
        :name
      )
    end
  end
end

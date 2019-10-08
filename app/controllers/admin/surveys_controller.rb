# frozen_string_literal: true

module Admin
  class SurveysController < BaseController
    add_breadcrumb 'Admin'
    add_breadcrumb 'Surveys', %i[admin surveys]

    before_action :set_survey, only: %i[show edit update]

    def index
      @surveys = Survey.order(id: :asc)
      authorize [:admin, Survey]
    end

    def show
      @questions = @survey
                     .questions
                     .order(position: :asc)
    end

    def edit
      authorize [:admin, @survey]

      add_breadcrumb @survey.title, admin_survey_path(@survey.to_param)
    end

    def update
      authorize [:admin, @survey]

      add_breadcrumb @survey.title, admin_survey_path(@survey.to_param)

      if @survey.update(survey_params)
        redirect_to [:admin, @survey], notice: 'Survey successfully updated.'
      else
        render :edit, alert: 'Survey could not be updated.'
      end
    end

    private

    def set_survey
      @survey = Survey.find(params[:id])
    end

    def survey_params
      params.require(:survey).permit(
        :title
      )
    end
  end
end

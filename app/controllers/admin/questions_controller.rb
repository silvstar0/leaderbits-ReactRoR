# frozen_string_literal: true

module Admin
  class QuestionsController < BaseController
    add_breadcrumb 'Admin'
    add_breadcrumb 'Surveys', %i[admin surveys]

    skip_before_action :verify_authenticity_token, only: %i[create update sort]
    before_action :set_survey, only: %i[show new create edit update destroy]
    before_action :set_question, only: %i[show edit update destroy]

    def show
      authorize [:admin, @question]
      add_breadcrumb @survey.title, admin_survey_path(@survey)
    end

    def new
      add_breadcrumb @survey.title, admin_survey_path(@survey)

      @question = @survey.questions.new params: {}
      authorize [:admin, @question]
    end

    def create
      question = @survey.questions.new params: question_params
      authorize [:admin, question]
      question.save!

      tags_csv = params.dig(:question, :tags_csv)
      if tags_csv.present?
        tags_csv.split(",").each do |label|
          @question.tags.create! label: label
        end
      end

      respond_to do |format|
        format.js do
          unobtrusive_flash.regular type: :notice, message: "Question successfully created"
          render json: { redirect: admin_survey_path(@survey) }
        end
      end
    end

    def edit
      authorize [:admin, @question]
    end

    def update
      authorize [:admin, @question]

      @question.params = question_params
      @question.save!

      tags_csv = params.dig(:question, :tags_csv)

      labels = tags_csv.to_s.split(",")
      @question.tags.where.not(label: labels).delete_all
      labels.each { |label| @question.tags.find_or_create_by! label: label }

      respond_to do |format|
        format.js { render json: { redirect: admin_survey_path(@survey) } }
      end
    end

    def destroy
      authorize [:admin, @question]

      @question.destroy

      redirect_to admin_survey_path(@survey), notice: 'Question successfully destroyed.'
    end

    def sort
      authorize [:admin, Question]
      survey = Survey.find params[:survey_id]

      params[:question].each.with_index(1) do |id, index|
        question = survey.questions.find(id)
        question.update_column :position, index
      end

      render js: "window.location.reload()"
    end

    private

    def question_params
      {
        title: params['title'],
        type: params['type'],
        left_side: params['left_side'],
        right_side: params['right_side'],
        mandatory: params['mandatory'].present? ? true : false,
        hint: params['hint']
      }
    end

    def set_survey
      @survey = Survey.find(params[:survey_id])
    end

    def set_question
      @question = Question.find(params[:id])
    end
  end
end

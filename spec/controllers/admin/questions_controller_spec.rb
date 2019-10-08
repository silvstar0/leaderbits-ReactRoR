# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::QuestionsController, type: :controller do
  describe "POST #create" do
    login_user

    let(:valid_attributes) {
      {
        title: "What do you think about X",
        type: Question::Types::SINGLE_TEXTBOX
      }
    }

    context "with valid params" do
      it 'creates mandatory question', login_factory: :system_admin_user do
        survey = create(:survey)

        expect {
          post :create, params: valid_attributes.merge(mandatory: "true", survey_id: survey.id), format: :js
        }.to change(Question, :count).by(1)

        expect(Question.last.params['mandatory']).to eq(true)
      end

      it 'creates optional question', login_factory: :system_admin_user do
        survey = create(:survey)

        expect {
          post :create, params: valid_attributes.merge(survey_id: survey.id), format: :js
        }.to change(Question, :count).by(1)

        expect(Question.last.params['mandatory']).to eq(false)
      end
    end
  end

  describe "POST #sort" do
    login_user

    example 'sorts questions in survey', login_factory: :system_admin_user do
      survey1 = create(:survey, type: Survey::Types::FOR_LEADER)

      create(:slider_question, survey: survey1)
      create(:single_textbox_question, survey: survey1)
      create(:commentbox_question, survey: survey1)

      valid_attribute = survey1.questions.pluck(:id).shuffle

      post :sort, params: { survey_id: survey1.id, question: valid_attribute }, xhr: true

      actual = survey1
                 .questions
                 .order(position: :asc)
                 .collect(&:id)

      expect(actual).to eq(valid_attribute)
    end
  end
end

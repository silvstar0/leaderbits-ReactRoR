# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::QuestionPolicy do
  subject { described_class.new(user, record) }

  describe '#show' do
    let(:record) { create(:single_textbox_question) }

    context 'given system admin' do
      let!(:user) { create(:system_admin_user) }

      it { is_expected.to permit_action(:show) }
    end

    context 'given employee' do
      let!(:user) do
        create(:user)
          .tap { |u| LeaderbitsEmployee.create! user: u, organization: Organization.first! }
      end

      it { is_expected.to permit_action(:show) }
    end

    context 'given random user' do
      let!(:user) { create(:user) }

      it { is_expected.to forbid_action(:show) }
    end
  end

  describe '#update' do
    let(:record) { create(:single_textbox_question) }

    context 'given system admin' do
      let!(:user) { create(:system_admin_user) }

      context 'given new question without any answers to it yet' do
        it { is_expected.to permit_action(:update) }
      end
      # context 'given question with some existing answers to it' do
      #   before do
      #     create(:answer_by_leader, question: record)
      #   end
      #
      #   it { is_expected.to forbid_action(:update) }
      # end
    end

    context 'given random user' do
      let!(:user) { create(:user) }

      context 'given new question without any answers to it yet' do
        it { is_expected.to forbid_action(:update) }
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationalMentorshipHelper, type: :helper do
  describe '#choose_mentee_collection' do
    subject { helper.choose_mentee_collection }

    let(:organization){ create(:organization) }
    let(:current_user) { create(:user, organization: organization) }

    before { allow(view).to receive(:current_user).and_return(current_user) }

    context 'given only users in organization' do
      before do
        create(:user, email: 'wycats@gmail.com', name: 'Yehuda Katz', organization: organization)
      end

      it { is_expected.to contain_exactly(OpenStruct.new(name: 'Yehuda Katz', email: 'wycats@gmail.com')) }
    end

    # context 'given only some anonymous survey participants' do
    #   before do
    #     create(:anonymous_survey_participant, added_by_user: current_user, email: 'john.b@gmail.com', name: 'John Brown')
    #   end
    #
    #   it { is_expected.to contain_exactly(OpenStruct.new(name: 'John Brown', email: 'john.b@gmail.com')) }
    # end
    #
    # context 'given some anonymous survey participants AND some users in current_user organization' do
    #   before do
    #     create(:anonymous_survey_participant, added_by_user: current_user, email: 'john.b@gmail.com', name: 'John Brown')
    #     create(:user, email: 'wycats@gmail.com', name: 'Yehuda Katz', organization: organization)
    #   end
    #
    #   it { is_expected.to contain_exactly(OpenStruct.new(name: 'John Brown', email: 'john.b@gmail.com'), OpenStruct.new(name: 'Yehuda Katz', email: 'wycats@gmail.com')) }
    # end
    #
    # context 'given anonymous survey participant who is also an existing user in org' do
    #   before do
    #     create(:anonymous_survey_participant, added_by_user: current_user, email: 'wycats@gmail.com', name: 'Yehuda')
    #     create(:user, email: 'wycats@gmail.com', name: 'Yehuda Katz', organization: organization)
    #   end
    #
    #   it { is_expected.to contain_exactly(OpenStruct.new(name: 'Yehuda', email: 'wycats@gmail.com')) }
    # end
  end
end

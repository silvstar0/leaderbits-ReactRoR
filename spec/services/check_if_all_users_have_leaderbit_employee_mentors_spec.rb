# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckIfAllUsersHaveLeaderbitEmployeeMentors do
  let(:organization) { create(:organization, leaderbits_sending_enabled: true) }
  let(:user) { create(:user, leaderbits_sending_enabled: true, organization: organization) }

  context 'given one incomplete leaderbit that we have not notified about yet' do
    example do
      expect {
        described_class.call
      }.not_to change { ActionMailer::Base.deliveries.count }

      expect {
        user
        described_class.call
      }.to change { ActionMailer::Base.deliveries.last&.subject }.to("Warning: 1 leader don't have LeaderBits employee-mentors")
    end
  end
end

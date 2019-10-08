# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IncompleteLeaderbitReminderMailerJob, type: :job do
  example do
    user = create(:user)
    leaderbit = create(:leaderbit)

    expect {
      described_class.perform_now user.id, leaderbit.id
    }.to change { ActionMailer::Base.deliveries.count }.from(0).to(1)
           .and change { ActionMailer::Base.deliveries.last&.subject }.from(nil).to("Incomplete challenge")
                  .and change { UserSentIncompleteLeaderbitReminder.where(user: user, resource: leaderbit).count }.from(0).to(1)
  end
end

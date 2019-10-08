# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduledNewLeaderbitMailerJob, type: :job do
  context 'given valid email' do
    it 'sends email and marks it as sent' do
      user = create(:user)
      leaderbit = create(:leaderbit)

      expect {
        described_class.perform_now user.id, leaderbit.id
      }.to change { ActionMailer::Base.deliveries.count }.from(0).to(1)
             .and change { ActionMailer::Base.deliveries.last&.subject }.from(nil).to("Welcome to LeaderBits.io")
                    .and change { UserSentScheduledNewLeaderbit.where(user: user, leaderbit: leaderbit).count }.from(0).to(1)
    end
  end

  context 'given invalid email' do
    it 'sends email and marks it as sent' do
      kind_of_invalid_message_postmark_error = Class.new(Postmark::InvalidMessageError) do
        def message
          "You tried to send to a recipient that has been marked as inactive. Found inactive addresses: j@aol.com. Inactive recipients are ones that have generated a hard bounce or a spam complaint."
        end
      end

      allow(LeaderbitMailer).to receive(:with).and_raise(kind_of_invalid_message_postmark_error)

      user = create(:user)
      leaderbit = create(:leaderbit)

      expect { described_class.perform_now user.id, leaderbit.id }.to change { BouncedEmail.last&.email }.from(nil).to('j@aol.com')
    end
  end
end

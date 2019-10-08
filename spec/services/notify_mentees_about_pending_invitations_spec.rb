# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotifyMenteesAboutPendingInvitations do
  context 'given 3 or 10 days old pending invitation' do
    it 'reminds about it' do
      organizational_mentorship = create(:organizational_mentorship, accepted_at: nil, created_at: [3, 10].sample.days.ago)
      ActionMailer::Base.deliveries = []
      expect {
        described_class.call
      }.to change { ActionMailer::Base.deliveries.last&.subject }.to("Reminder: Mentor invitation from #{organizational_mentorship.mentor_user.name}")
    end

    it 'does not remind twice in case service is called multiple times a day' do
      organizational_mentorship = create(:organizational_mentorship, accepted_at: nil, created_at: [3, 10].sample.days.ago)
      ActionMailer::Base.deliveries = []
      expect {
        described_class.call
        described_class.call
      }.to change { ActionMailer::Base.deliveries.count }.to(1)
             .and change { ActionMailer::Base.deliveries.last&.subject }.to("Reminder: Mentor invitation from #{organizational_mentorship.mentor_user.name}")
    end
  end

  context 'given 3 days old accepted invitation' do
    it 'does not remind about it' do
      create(:organizational_mentorship, accepted_at: 2.minutes.ago, created_at: 3.days.ago)
      ActionMailer::Base.deliveries = []
      expect {
        described_class.call
      }.not_to change { ActionMailer::Base.deliveries.last&.subject }.from(nil)
    end
  end

  context 'given pending invitation from days that we skip' do
    it 'stays silent' do
      create(:organizational_mentorship, accepted_at: nil, created_at: [1, 2, 4, 5, 6, 7, 8, 9].sample.days.ago)
      ActionMailer::Base.deliveries = []
      expect {
        described_class.call
      }.not_to change { ActionMailer::Base.deliveries.last&.subject }.from(nil)
    end
  end
end

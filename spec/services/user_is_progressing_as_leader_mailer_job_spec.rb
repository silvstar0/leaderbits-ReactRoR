# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserIsProgressingAsLeaderMailerJob do
  let(:added_by_user) { create(:user, created_at: 40.days.ago, organization: organization) }
  let(:organization) { create(:organization, active_since: 7.weeks.ago) }
  let(:user2) { create(:user, organization: organization) }
  let(:leaderbit) { create(:active_leaderbit) }

  context 'given weekly progress report recipient' do
    example do
      create(:progress_report_recipient, added_by_user: added_by_user, user: user2, frequency: ProgressReportRecipient::Frequencies::WEEKLY)

      expect { described_class.call }.not_to change(UserSentUserIsProgressingAsLeader, :count)

      create(:entry, discarded_at: nil, leaderbit: leaderbit, user: added_by_user, created_at: 2.days.ago, updated_at: 2.days.ago)
      create(:leaderbit_log, leaderbit: leaderbit, user: added_by_user, status: LeaderbitLog::Statuses::COMPLETED, updated_at: 2.days.ago)

      expect { described_class.call }.to change(UserSentUserIsProgressingAsLeader, :count).to(1)

      # do not run in again in case email has already been sent today
      # this maybe in case some time in the future there is a bug in this job and we want to resume it
      expect { described_class.call }.not_to change(UserSentUserIsProgressingAsLeader, :count)
    end
  end

  context 'given bi-monthly progress report recipient' do
    example do
      create(:progress_report_recipient, added_by_user: added_by_user, user: user2, frequency: ProgressReportRecipient::Frequencies::BIMONTHLY)

      expect { described_class.call }.not_to change(UserSentUserIsProgressingAsLeader, :count)

      create(:entry, discarded_at: nil, leaderbit: leaderbit, user: added_by_user, created_at: 13.days.ago, updated_at: 13.days.ago)
      create(:leaderbit_log, leaderbit: leaderbit, user: added_by_user, status: LeaderbitLog::Statuses::COMPLETED, updated_at: 13.days.ago)

      expect { described_class.call }.to change(UserSentUserIsProgressingAsLeader, :count).to(1)

      # do not run in again in case email has already been sent today
      # this maybe in case some time in the future there is a bug in this job and we want to resume it
      expect { described_class.call }.not_to change(UserSentUserIsProgressingAsLeader, :count)
    end
  end

  context 'given recently sent progress report' do
    it 'skips it again until next reporting period' do
      create(:progress_report_recipient, added_by_user: added_by_user, user: user2, frequency: ProgressReportRecipient::Frequencies::MONTHLY)

      user2.user_sent_user_is_progressing_as_leaders.create! resource: added_by_user, created_at: 25.days.ago

      create(:entry, discarded_at: nil, leaderbit: leaderbit, user: added_by_user, created_at: 1.day.ago, updated_at: 1.day.ago)
      create(:leaderbit_log, leaderbit: leaderbit, user: added_by_user, status: LeaderbitLog::Statuses::COMPLETED, updated_at: 1.day.ago)

      expect { described_class.call }.not_to change(UserSentUserIsProgressingAsLeader, :count)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MonthlyProgressReportsMailer do
  example do
    create(:user, created_at: 40.days.ago)

    user2 = create(:user, created_at: 40.days.ago)
    create(:user_sent_scheduled_new_leaderbit, user: user2)

    expect { described_class.call }.to change(UserSentMonthlyProgressReport, :count).by(1)
    #next run acknowledges emails that were just sent
    expect { described_class.call }.not_to change(UserSentMonthlyProgressReport, :count)
  end
end

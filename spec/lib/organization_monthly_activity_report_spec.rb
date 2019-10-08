# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationMonthlyActivityReport do
  example do
    organization = create(:organization)
    user = create(:user, organization: organization)

    2.times do |i|
      create(:leaderbit_log,
             user: user,
             status: LeaderbitLog::Statuses::COMPLETED,
             updated_at: (35 + i).days.ago,
             leaderbit: create(:leaderbit))
    end

    5.times do |i|
      create(:leaderbit_log,
             user: user,
             status: LeaderbitLog::Statuses::COMPLETED,
             updated_at: (1 + i).days.ago,
             leaderbit: create(:leaderbit))
    end

    report = described_class.new([organization])
    expect(report.increment_for_organization(organization.reload)).to include('+ 150%')
  end
end

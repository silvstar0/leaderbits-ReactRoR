# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserIsSlackingOffMailerJob do
  let(:organization) { create(:organization, active_since: 7.weeks.ago) }
  let(:schedule) { Schedule.create!(name: Schedule::GLOBAL_NAME).tap { |schedule| schedule.leaderbit_schedules.create! leaderbit: create(:active_leaderbit) } }

  context 'given leader inactive for 3-weeks' do
    before do
      @user = create(:user, created_at: 24.days.ago, schedule: schedule, organization: organization,)
      progress_report_recipient = create(:progress_report_recipient, added_by_user: @user)
      @user.update_attribute(:notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks, progress_report_recipient.id)
    end

    it 'notifies chosen progress report recipient in case leader is slacking off' do
      expect { described_class.call }.to change(UserSentEmail, :count).to(1)
                                           .and change { ActionMailer::Base.deliveries.count }.to(1)
                                                  .and change { ActionMailer::Base.deliveries.last&.subject }.to("#{@user.first_name} is slacking off")
    end

    it 'notifies just once' do
      expect { described_class.call; described_class.call }.to change(UserSentEmail, :count).to(1)
                                                                 .and change { ActionMailer::Base.deliveries.count }.to(1)
                                                                        .and change { ActionMailer::Base.deliveries.last&.subject }.to("#{@user.first_name} is slacking off")
    end
  end

  context 'given leader inactive for long time' do
    it 'does not notify' do
      user = create(:user, created_at: 36.days.ago, schedule: schedule, organization: organization,)
      progress_report_recipient = create(:progress_report_recipient, added_by_user: user)
      user.update_attribute(:notify_progress_report_recipient_id_if_i_miss_more_than_3_weeks, progress_report_recipient.id)

      expect { described_class.call }.not_to change(UserSentEmail, :count)
    end
  end
end

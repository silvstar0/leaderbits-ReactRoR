# frozen_string_literal: true

# Why do we need leaderit sending plan/actual, LeaderbitSendingAnomalyDetection and extensive testing in HourlySendingOfLeaderbitEmails service?
# because that's the very core business feature of LeaderBits and because Joel requested it
class HourlyLeaderbitSendingSummaryLog
  include HasUsersToSendLeaderbitsTo

  def self.call(now = Time.now)
    # needed for only for release planning to choose the less busy sending hours
    save_upcoming_12_hours_plan now

    # NOTE: see LeaderbitSendingAnomalyDetection to understand whythis
    # 2-phase(set current hour/update previous hour plan) approach was used(long story short - to catch inconsistency sooner)
    save_current_hour_send_plan now
    update_previous_hour_actual_sent now
  end

  def self.save_upcoming_12_hours_plan(now)
    # yes that's 1.5 days ahead but it's OK since in blazer we only display non-zero values.
    # and because it is relatively fast.
    (0..36).each do |i|
      t1 = i.hours.since(now)
      Timecop.freeze(t1) do
        #TODO you may abstract User.active_recipient here and in HourlySendinfOfLeaderbitEmails

        expected = User
                     .active_recipient
                     .inject(0) { |count, user| send_during_this_hour?(user) ? count + 1 : count }

        summary = HourlyLeaderbitSendingSummary
                    .where('created_at >= ? AND created_at <= ?', t1.beginning_of_hour, t1.end_of_hour)
                    .first

        if summary.present?
          #why it could be present?
          summary.to_be_sent_quantity = expected
          summary.save!
        else
          HourlyLeaderbitSendingSummary.create! created_at: t1,
                                                to_be_sent_quantity: expected,
                                                actual_sent_quantity: nil
        end
      end
    end
  end

  def self.save_current_hour_send_plan(now)
    #TODO you may abstract User.active_recipient here and in HourlySendinfOfLeaderbitEmails
    expected = User
                 .active_recipient
                 .inject(0) do |count, user|
      Timecop.freeze(now) do
        send_during_this_hour?(user) ? count + 1 : count
      end
    end

    summary = HourlyLeaderbitSendingSummary
                .where('created_at >= ? AND created_at <= ?', now.beginning_of_hour, now.end_of_hour)
                .first

    # in could be present in cases
    #   * this task has been called multiple times during short period(manually debugging?)
    #   * hourly_leaderbit_sending_summary has been recently created by #save_upcoming_12_hours_plan
    if summary.present?
      # updating sending plan to the most accurate(previous data was approximate in case nothing changes in the system)
      summary.to_be_sent_quantity = expected
      summary.save!
    else
      HourlyLeaderbitSendingSummary.create! created_at: now,
                                            to_be_sent_quantity: expected,
                                            actual_sent_quantity: nil
    end
  end

  def self.update_previous_hour_actual_sent(now)
    t2 = 1.hour.until(now)

    summary = HourlyLeaderbitSendingSummary
                .where('created_at >= ? AND created_at <= ?', t2.beginning_of_hour, t2.end_of_hour)
                .first
    unless summary.present?
      Rails.logger.warn("why summary could be missing?  first time running this cron job? #{t2.inspect}")
      Rollbar.scoped(t2: t2) do
        Rollbar.error("why summary could be missing?  first time running this cron job?")
      end
      return
    end

    summary.actual_sent_quantity = UserSentScheduledNewLeaderbit
                                     .where('created_at >= ? AND created_at <= ?', t2.beginning_of_hour, t2.end_of_hour)
                                     .count
    summary.save!
  end

  private_class_method :save_current_hour_send_plan
  private_class_method :update_previous_hour_actual_sent
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: hourly_leaderbit_sending_summaries
#
#  id                   :bigint(8)        not null, primary key
#  to_be_sent_quantity  :integer
#  actual_sent_quantity :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class HourlyLeaderbitSendingSummary < ApplicationRecord
end

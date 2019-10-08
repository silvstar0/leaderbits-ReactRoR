# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                                                                                                              :bigint(8)        not null, primary key
#  name                                                                                                            :string           not null
#  created_at                                                                                                      :datetime         not null
#  updated_at                                                                                                      :datetime         not null
#  first_leaderbit_introduction_message                                                                            :text
#  hour_of_day_to_send                                                                                             :integer          default(9)
#  day_of_week_to_send                                                                                             :string           default("Monday")
#  discarded_at                                                                                                    :datetime
#  custom_default_schedule_id                                                                                      :integer
#  leaderbits_sending_enabled                                                                                      :boolean          default(TRUE), not null
#  stripe_customer_id                                                                                              :string
#  active_since(needed in cases when organization is created prematurely but it must be activated on certain date) :datetime         not null
#  users_count                                                                                                     :integer
#

require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe '#intercom_custom_data' do
    example do
      organization = build_stubbed(:organization)
      result = organization.intercom_custom_data
      expect(result.keys).to contain_exactly(:name, :created_at)
    end
  end
end

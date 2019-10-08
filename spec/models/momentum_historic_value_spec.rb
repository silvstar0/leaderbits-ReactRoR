# frozen_string_literal: true

# == Schema Information
#
# Table name: momentum_historic_values
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  value      :integer          not null
#  created_on :date             not null
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe MomentumHistoricValue, type: :model do
  describe 'validations' do
    example do
      expect do
        create(:momentum_historic_value, value: 0, created_on: 100.days.ago)
        create(:momentum_historic_value, value: 1, created_on: 99.days.ago)
        create(:momentum_historic_value, value: 100, created_on: 10.days.ago)
      end.not_to raise_error

      expect { create(:momentum_historic_value, value: 101, created_on: 10.days.ago) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end

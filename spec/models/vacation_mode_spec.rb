# frozen_string_literal: true

# == Schema Information
#
# Table name: vacation_modes
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  reason     :text
#  starts_at  :datetime         not null
#  ends_at    :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe VacationMode, type: :model do
  describe 'validations' do
    let(:user) { create(:user) }

    it 'does not allow new future vacation if there is one already happening' do
      vm = build(:vacation_mode, user: user, starts_at: 2.days.ago.to_date, ends_at: 2.days.from_now.to_date)
      vm.save validate: false

      expect(described_class.count).to eq(1)

      expect { create(:vacation_mode, user: user, starts_at: 5.days.ago.to_date, ends_at: 10.days.from_now.to_date) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'does not retroactively create already started vacation mode' do
      expect { create(:vacation_mode, user: user, starts_at: 2.days.ago.to_date, ends_at: 2.days.from_now.to_date) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'allows user to create vacation mode that starts right away' do
      expect { create(:vacation_mode, user: user, starts_at: Time.now, ends_at: 2.days.from_now.to_date) }.not_to raise_error
    end

    it 'does not allow to create multiple upcoming vacation modes' do
      create(:vacation_mode, user: user, starts_at: 2.days.from_now.to_date, ends_at: 5.days.from_now.to_date)

      expect { create(:vacation_mode, user: user, starts_at: 10.days.from_now.to_date, ends_at: 15.days.from_now.to_date) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'does not allow starts_at to be later than ends_at' do
      expect { create(:vacation_mode, user: user, starts_at: 4.days.from_now.to_date, ends_at: 2.days.from_now.to_date) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end

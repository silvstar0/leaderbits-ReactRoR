# frozen_string_literal: true

# == Schema Information
#
# Table name: progress_report_recipients
#
#  id               :bigint(8)        not null, primary key
#  frequency        :string           not null
#  added_by_user_id :bigint(8)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint(8)        not null
#
# Foreign Keys
#
#  fk_rails_...  (added_by_user_id => users.id)
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe ProgressReportRecipient, type: :model do
  describe 'validations' do
    example do
      user1 = create(:user)
      user2 = create(:user)

      create(:progress_report_recipient, added_by_user: user1, user: user2)

      expect { create(:progress_report_recipient, added_by_user: user1, user: user2) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end

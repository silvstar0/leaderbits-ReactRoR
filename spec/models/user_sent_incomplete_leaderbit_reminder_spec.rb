# frozen_string_literal: true

# == Schema Information
#
# Table name: user_sent_emails
#
#  id            :bigint(8)        not null, primary key
#  user_id       :bigint(8)        not null
#  resource_id   :bigint(8)
#  created_at    :datetime         not null
#  resource_type :string
#  type          :string
#  params        :json
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe UserSentIncompleteLeaderbitReminder, type: :model do
  describe 'validations' do
    let(:user) { create(:user) }
    let(:leaderbit1) { create(:leaderbit) }

    it 'prevents same leaderbit from being sent multiple times' do
      create(:user_sent_incomplete_leaderbit_reminder, user: user, resource: leaderbit1)
      expect { create(:user_sent_incomplete_leaderbit_reminder, user: user, resource: leaderbit1) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end

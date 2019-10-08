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

RSpec.describe UserSentScheduledNewLeaderbit, type: :model do
  describe 'validations' do
    example do
      expect { create(:user_sent_scheduled_new_leaderbit, resource: nil, resource_id: nil, resource_type: nil) }.to raise_error(ActiveRecord::RecordInvalid)
      expect { create(:user_sent_scheduled_new_leaderbit, resource: create(:user)) }.to raise_error(ActiveRecord::RecordInvalid)

      leaderbit1 = create(:leaderbit)
      create(:user_sent_scheduled_new_leaderbit, resource: leaderbit1)

      expect { create(:user_sent_scheduled_new_leaderbit, resource: leaderbit1) }.not_to raise_error
    end
  end

  describe 'user cache invalidation' do
    it 'is done upon new record creation' do
      user = create(:user)

      expect {
        create(:user_sent_scheduled_new_leaderbit, user: user)
      }.to change { user.reload.cache_key_with_version }.from(user.cache_key_with_version)
    end
  end
end

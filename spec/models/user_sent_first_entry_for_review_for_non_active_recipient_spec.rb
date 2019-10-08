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

RSpec.describe UserSentFirstEntryForReviewForNonActiveRecipient, type: :model do
  describe 'validations' do
    it 'allows only one instance of such type per user' do
      user1 = create(:user)
      user2 = create(:user)

      expect { described_class.create!(user: user1) }.to change(described_class, :count)
      expect { described_class.create!(user: user1) }.to raise_error(ActiveRecord::RecordInvalid)

      expect { described_class.create!(user: user2) }.to change(described_class, :count)
    end
  end
end

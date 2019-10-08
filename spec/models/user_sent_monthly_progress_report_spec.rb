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

RSpec.describe UserSentMonthlyProgressReport, type: :model do
  describe 'validations' do
    example do
      user = create(:user)

      described_class.create! user: user

      expect { described_class.create! user: user, resource: create(:user) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end

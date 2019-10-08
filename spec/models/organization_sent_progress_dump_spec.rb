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

RSpec.describe OrganizationSentProgressDump, type: :model do
  describe 'validations' do
    example do
      expect { create(:organization_sent_progress_dump, resource: nil, resource_id: nil, resource_type: nil) }.to raise_error(ActiveRecord::RecordInvalid)
      expect { create(:organization_sent_progress_dump, resource: create(:user)) }.to raise_error(ActiveRecord::RecordInvalid)

      expect { create(:organization_sent_progress_dump, resource: create(:organization)) }.not_to raise_error
    end
  end

  describe '#human_description' do
    example do
      organization = create(:organization)

      expect(create(:organization_sent_progress_dump, resource: organization).human_description).to eq("Account \"#{organization.name}\" Lifetime progress report")
    end
  end
end

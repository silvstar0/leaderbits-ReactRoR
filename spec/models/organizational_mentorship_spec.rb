# frozen_string_literal: true

# == Schema Information
#
# Table name: organizational_mentorships
#
#  id             :bigint(8)        not null, primary key
#  mentor_user_id :bigint(8)        not null
#  mentee_user_id :bigint(8)        not null
#  created_at     :datetime         not null
#  accepted_at    :datetime
#
# Foreign Keys
#
#  fk_rails_...  (mentee_user_id => users.id)
#  fk_rails_...  (mentor_user_id => users.id)
#

require 'rails_helper'

RSpec.describe OrganizationalMentorship, type: :model do
  describe 'validations' do
    example do
      user1 = create(:user)
      user2 = create(:user)

      create(:organizational_mentorship, mentor_user: user1, mentee_user: user2)
      expect { create(:organizational_mentorship, mentor_user: user1, mentee_user: user2) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'cache invalidation' do
    it 'invalides on creation' do
      user1 = create(:user)
      user2 = create(:user)

      expect { create(:organizational_mentorship, mentor_user: user1, mentee_user: user2) }.to change { user1.reload.cache_key_with_version }
                                                                                                 .and change { user2.reload.cache_key_with_version }
    end

    it 'invalides on destroying' do
      user1 = create(:user)
      user2 = create(:user)
      mentorship = create(:organizational_mentorship, mentor_user: user1, mentee_user: user2)

      expect { mentorship.destroy! }.to change { user1.reload.cache_key_with_version }
                                          .and change { user2.reload.cache_key_with_version }
    end
  end
end

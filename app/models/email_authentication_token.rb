# frozen_string_literal: true

# == Schema Information
#
# Table name: email_authentication_tokens
#
#  id                   :bigint(8)        not null, primary key
#  authentication_token :string(30)       not null
#  user_id              :bigint(8)        not null
#  created_at           :datetime         not null
#  valid_until          :datetime
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class EmailAuthenticationToken < ApplicationRecord
  NEW_AUTHENTICATION_TOKEN_SHELF_LIFE = 3.weeks.freeze

  belongs_to :user

  validates :valid_until, presence: true, allow_blank: false, allow_nil: false
  validates :authentication_token, uniqueness: true, presence: true, allow_nil: false, allow_blank: false
end

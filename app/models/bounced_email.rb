# frozen_string_literal: true

# == Schema Information
#
# Table name: bounced_emails
#
#  id         :bigint(8)        not null, primary key
#  email      :string           not null
#  message    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BouncedEmail < ApplicationRecord
  validates :email, presence: true, allow_nil: false, allow_blank: false
  validates :message, presence: true, allow_nil: false, allow_blank: false
end

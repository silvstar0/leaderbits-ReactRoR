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

FactoryBot.define do
  factory :bounced_email do
    email { Faker::Internet.email }
    message { <<~MSG }
      You tried to send to a recipient that has been marked as inactive.
      Found inactive addresses: oskar@mobject.com.
      Inactive recipients are ones that have generated a hard bounce or a spam complaint.
    MSG
  end
end

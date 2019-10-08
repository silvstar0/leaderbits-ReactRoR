# frozen_string_literal: true

FactoryBot.define do
  factory :email_authentication_token do
    authentication_token { Faker::Invoice.creditor_reference }
    user
    valid_until { 3.weeks.from_now }
  end
end

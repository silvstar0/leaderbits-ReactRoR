# frozen_string_literal: true

# == Schema Information
#
# Table name: anonymous_survey_participants
#
#  id                                                                                                                                                  :bigint(8)        not null, primary key
#  added_by_user_id(leader-user who requested (email; name) to participate in anonymous survey)                                                        :bigint(8)        not null
#  email                                                                                                                                               :string           not null
#  created_at                                                                                                                                          :datetime         not null
#  uuid(needed because we can identify anon user only by this field as GET param accessed from sent email where we requested to participate in survey) :string           not null
#  name                                                                                                                                                :string           not null
#  role                                                                                                                                                :string           not null
#
# Foreign Keys
#
#  fk_rails_...  (added_by_user_id => users.id)
#

FactoryBot.define do
  factory :anonymous_survey_participant do
    association :added_by_user, factory: :user
    email {
      handle = Faker::Internet.user_name(specifier: name, separators: %w(. _ -))
      # NOTE: it is important not to use fake .example.com emails because it may affect Postmark rating
      "#{handle}@leaderbits.io" # any@leaderbits.io doesn't trigger hard bounces
    }

    name { Faker::Name.name }
    role { AnonymousSurveyParticipant::Roles::ALL.sample }
  end
end

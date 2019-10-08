# frozen_string_literal: true

# == Schema Information
#
# Table name: leaderbits
#
#  id                       :bigint(8)        not null, primary key
#  name                     :string           not null
#  desc                     :text             not null
#  url                      :string           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  image                    :string           default("default.png")
#  body                     :text             not null
#  active                   :boolean          default(FALSE)
#  user_action_title_suffix :string           not null
#  entry_prefilled_text     :text
#

FactoryBot.define do
  factory :leaderbit do
    sequence(:name) { |n| "Leaderbit Name ##{n}" }
    desc { Faker::Lorem.sentence }
    body { Faker::Lorem.sentence }
    user_action_title_suffix do
      [
        'just learned how they could become more valuable to their team.',
        'just connected the value of their work back to the customer.',
        'identifed a clear and intentional outcome for their work today.'
      ].sample
    end
    url { [Faker::Internet.url(scheme: 'https', host: 'player.vimeo.com'), 'https://player.vimeo.com/video/273215632'].sample }

    active { [true, false].sample }
  end

  factory :active_leaderbit, parent: :leaderbit do
    active { true }
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id              :bigint(8)        not null, primary key
#  name            :string           not null
#  organization_id :bigint(8)        not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#

FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }
    organization
  end
end

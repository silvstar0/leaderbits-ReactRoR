# frozen_string_literal: true

# == Schema Information
#
# Table name: team_members
#
#  id         :bigint(8)        not null, primary key
#  role       :string           not null
#  user_id    :bigint(8)
#  team_id    :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TeamMember < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :team, touch: true

  validates :user, uniqueness: { scope: :team }, allow_blank: false, allow_nil: false

  accepts_nested_attributes_for :user

  module Roles
    LEADER = 'leader'
    MEMBER = 'member'

    ALL = [
      LEADER,
      MEMBER
    ].freeze
  end

  enum role: Roles::ALL.each_with_object({}) { |v, h| h[v] = v }
end

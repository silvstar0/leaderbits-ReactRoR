# frozen_string_literal: true

# == Schema Information
#
# Table name: surveys
#
#  id                                :bigint(8)        not null, primary key
#  type                              :string           not null
#  title                             :string           not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  anonymous_survey_participant_role :string
#

class Survey < ApplicationRecord
  module Types
    FOR_LEADER = 'for_leader'

    # think of "follower" as antonym of "leader".
    # People who are managed by leader and anonymously evaluate his/her performance
    FOR_FOLLOWER = 'for_follower'

    ALL = [
      FOR_LEADER,
      FOR_FOLLOWER
    ].freeze
  end

  audited

  enum type: Survey::Types::ALL.each_with_object({}) { |v, h| h[v] = v }

  # with_options allow_nil: false, allow_blank: false do
  #   validates :title, uniqueness: true
  #   validates :type, inclusion: { in: Types::ALL }, uniqueness: true, presence: true
  # end
  #
  def self.leadership_strangths_finder
    for_leader.where(title: 'Leadership Strengths Finder').first!
  end

  has_many :questions

  def to_param
    [id, title.parameterize].join("-")
  end

  def self.inheritance_column
    nil
  end
end

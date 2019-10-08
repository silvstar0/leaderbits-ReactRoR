# frozen_string_literal: true

# == Schema Information
#
# Table name: user_sent_emails
#
#  id            :bigint(8)        not null, primary key
#  user_id       :bigint(8)        not null
#  resource_id   :bigint(8)
#  created_at    :datetime         not null
#  resource_type :string
#  type          :string
#  params        :json
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

#NOTE: not all "organization sent progress dumps" have corresponding records
#because in order to send one admin need to explicitely specify recipient email
#so we create record only in case we have an existing user with such email
class OrganizationSentProgressDump < UserSentEmail
  alias_attribute :organization, :resource

  audited

  validates :resource, presence: true
  validate :validate_resource_type

  def human_description(*)
    %(Account "#{resource.name}" Lifetime progress report)
  end

  def visible_in_engagement?
    false
  end

  private

  def validate_resource_type
    return if errors[:resource].present?
    return if resource_type.to_s == Organization.to_s

    errors.add(:resource_type, :invalid)
  end
end

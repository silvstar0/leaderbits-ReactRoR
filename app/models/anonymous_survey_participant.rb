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

# TODO actual sending metadata looks like another table responsibility
class AnonymousSurveyParticipant < ApplicationRecord
  belongs_to :added_by_user, class_name: 'User', touch: true

  module Roles
    #when I add a person and choose "direct report" it means this person reports to me. I am the leader.
    DIRECT_REPORT = 'direct_report'

    # when I add a person and choose "leader or mentor" it means this person is my leader or mentor. I am the employee.
    LEADER_OR_MENTOR = 'leader-or-mentor'

    PEER = 'peer'

    #NOTE: in the past we also had the "other" option but we decided to remove it(only 1 user used that option)

    DEFAULT = DIRECT_REPORT

    ALL = [
      DIRECT_REPORT,
      LEADER_OR_MENTOR,
      PEER
    ].freeze
  end

  enum type: Roles::ALL.each_with_object({}) { |v, h| h[v] = v }

  before_validation do
    self.email = email.downcase if email.present?
    self.uuid = generate_uuid if uuid.blank?
  end

  after_create_commit :mailer_notify

  with_options allow_nil: false, allow_blank: false do
    validates :email, uniqueness: { scope: :added_by_user }
    validates :name, presence: true

    validates :uuid, uniqueness: true
    validates :role, inclusion: { in: Roles::ALL }, presence: true
  end

  private

  def mailer_notify
    UserMailer
      .with(anonymous_survey_participant_id: id)
      .invitation_to_participate_anonymously_in_survey
      .deliver_later
  end

  def generate_uuid
    loop do
      uuid = SecureRandom.base64.tr('+/=', 'Qrt')
      break uuid unless AnonymousSurveyParticipant.exists?(uuid: uuid)
    end
  end
end

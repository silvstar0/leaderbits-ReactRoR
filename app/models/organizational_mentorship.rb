# frozen_string_literal: true

# == Schema Information
#
# Table name: organizational_mentorships
#
#  id             :bigint(8)        not null, primary key
#  mentor_user_id :bigint(8)        not null
#  mentee_user_id :bigint(8)        not null
#  created_at     :datetime         not null
#  accepted_at    :datetime
#
# Foreign Keys
#
#  fk_rails_...  (mentee_user_id => users.id)
#  fk_rails_...  (mentor_user_id => users.id)
#

class OrganizationalMentorship < ApplicationRecord
  belongs_to :mentor_user, class_name: 'User', touch: true
  belongs_to :mentee_user, class_name: 'User', touch: true

  validates :mentee_user, uniqueness: { scope: :mentor_user }, allow_blank: false, allow_nil: false
  #TODO add validation - mentee or mentor must be from the same org, otherwise it is a bug

  # needed for #fields_for in organizational_mentorships/form
  def email
    mentee_user ? mentee_user.email : nil
  end

  # needed for #fields_for in organizational_mentorships/form
  def name
    mentee_user ? mentee_user.name : nil
  end

  #NOTE: do not add this method as after create callback because it is important to explicitely
  # and manually set email sending status in this case
  def mailer_notify
    #TODO-low is there a better way for sending it?
    # this is because we're testing it in capybara-email
    UserMailer
      .with(organizational_mentorship_id: id)
      .invitation_to_become_mentee
      .yield_self { |mail_message| Rails.env.test? || Rails.env.development? ? mail_message.deliver_now : mail_message.deliver_later }

    UserSentInvitationToBecomeMentee.create!(user: mentee_user, resource: self)
  end
end

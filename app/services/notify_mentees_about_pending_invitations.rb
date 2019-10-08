# frozen_string_literal: true

class NotifyMenteesAboutPendingInvitations
  def self.call
    created_at_periods = [
      3.days.ago.beginning_of_day..3.days.ago.end_of_day,
      10.days.ago.beginning_of_day..10.days.ago.end_of_day
    ]

    OrganizationalMentorship.where(accepted_at: nil).where(created_at: created_at_periods).each do |organizational_mentorship|
      #prevents double sending in case this service/task is called multiple time accidentally
      t1 = Time.zone.now
      next if UserSentReminderAboutPendingInvitationToBecomeMentee
                .where(created_at: t1.beginning_of_day..t1.end_of_day)
                .where(user: organizational_mentorship.mentee_user, resource: organizational_mentorship)
                .exists?

      #TODO-low is there a better way for sending it?
      # this is because we're testing it in rspec
      UserMailer
        .with(organizational_mentorship_id: organizational_mentorship.id)
        .reminder_about_pending_invitation_to_become_mentee
        .yield_self { |mail_message| Rails.env.test? ? mail_message.deliver_now : mail_message.deliver_later }

      UserSentReminderAboutPendingInvitationToBecomeMentee.create!(user: organizational_mentorship.mentee_user, resource: organizational_mentorship)
    end
  end
end

# frozen_string_literal: true

module OrganizationalMentorshipHelper
  #All users in organization(except for current_user himself)?
  #Joel: "Mentee will likely be (but not always) a team member they have already entered."
  # @return [Object] collection of object where each element respond to #email and #name
  #TODO-High rename
  def choose_mentee_collection
    exclude_emails = OrganizationalMentorship
                       .where(mentor_user_id: current_user.id)
                       .includes(:mentee_user)
                       .collect(&:mentee_user)
                       .collect(&:email)

    current_user
      .organization
      .users
      .where.not(id: current_user.id)
      .where.not(schedule_id: nil)
      .collect { |user| OpenStruct.new(name: user.name, email: user.email) }
      .uniq(&:email)
      .sort_by(&:name)
      .delete_if { |ostruct| exclude_emails.include? ostruct[:email] }
  end
end

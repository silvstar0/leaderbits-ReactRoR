# frozen_string_literal: true

module Admin
  #TODO do we still need this controller?
  class OrganizationalMentorshipsController < BaseController
    def create
      #TODO arguments should be renamed for better clarity and predictability
      user = User.where(uuid: params[:user_id]).first!
      mentor_user = User.where(id: params[:mentor_user_id]).first!

      #NOTE: both conditions do not trigger email notification
      organizational_mentorship = OrganizationalMentorship.where(mentor_user: mentor_user, mentee_user: user).first
      if organizational_mentorship.present?
        organizational_mentorship.touch(:accepted_at)
      else
        OrganizationalMentorship.create! mentor_user: mentor_user, mentee_user: user, accepted_at: Time.now
      end

      redirect_back(fallback_location: edit_admin_user_path(user), notice: 'Mentor successfully assigned.')
    end

    def destroy
      @organizational_mentorship = OrganizationalMentorship.find(params[:id])
      @organizational_mentorship.destroy!

      redirect_to edit_admin_user_path(@organizational_mentorship.mentee_user), notice: 'Mentor successfully detached.'
    end
  end
end

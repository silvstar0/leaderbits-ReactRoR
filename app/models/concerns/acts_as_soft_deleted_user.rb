# frozen_string_literal: true

module ActsAsSoftDeletedUser
  extend ActiveSupport::Concern

  include Discard::Model

  # NOTE: simple_token_authentication skips active_for_authentication? check just as it skips sign_in_count incrementing
  # @see https://github.com/jhawthorn/discard/pull/9
  def active_for_authentication?
    #we're handling 2 use cases here
    # 1) users soft-deleted by admin(users can not discard/disable/soft-disable themselves as of Nov 2018 )
    # 2) technical users which are just progress report recipients/watchers - we allow them to be "logged in" so they can see corresponding entry_groups#show pages

    #NOTE: remember to call the super
    return false unless super

    return false if organization.active_since > Time.zone.now

    return true if technical_user_progress_report_recipient?

    !discarded?
  end

  def inactive_message
    "Your account is currently locked"
  end
end

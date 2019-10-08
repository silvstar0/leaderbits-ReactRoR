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

# STI base model. Think of it as a way to add transparency and visibility into current status of email sending.
class UserSentEmail < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :resource, polymorphic: true, optional: true

  # current_user: named argument is provided by default
  def human_description(*)
    raise NotImplementedError, "#{self.class} must override #{__method__}"
  end

  def visible_in_engagement?
    raise NotImplementedError, "#{self.class} must override #{__method__}"
  end
end

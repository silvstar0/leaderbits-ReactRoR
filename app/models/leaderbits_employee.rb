# frozen_string_literal: true

# == Schema Information
#
# Table name: leaderbits_employees
#
#  id              :bigint(8)        not null, primary key
#  user_id         :bigint(8)
#  organization_id :bigint(8)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class LeaderbitsEmployee < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :organization, touch: true

  validates :user, uniqueness: { scope: :organization }, allow_blank: false, allow_nil: false
end

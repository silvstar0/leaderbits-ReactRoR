# frozen_string_literal: true

# == Schema Information
#
# Table name: vacation_modes
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  reason     :text
#  starts_at  :datetime         not null
#  ends_at    :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class VacationMode < ApplicationRecord
  belongs_to :user

  audited

  with_options presence: true, allow_nil: false, allow_blank: false do
    validates :starts_at
    validates :ends_at
  end

  validates :user, uniqueness: { scope: %i[starts_at ends_at] }

  validate do
    next if errors[:starts_at].present? || errors[:ends_at].present?
    next if changes[:start_at].blank? && changes[:ends_at].blank?

    if starts_at < Time.now.beginning_of_day
      errors.add(:starts_at, :invalid, message: 'is in past date')
      next
    end

    unless ends_at > starts_at
      errors.add(:starts_at, :invalid, message: 'is later than ends at')
      next
    end
  end

  validate do
    next if errors[:starts_at].present? || errors[:ends_at].present?
    next if persisted?

    if VacationMode.where(user: user).where('starts_at > ?', Time.now).exists?
      errors.add(:starts_at, :invalid)
      next
    end
  end
end

# frozen_string_literal: true

class SaveHistoricMomentumValues
  def self.call_for_all
    User.active_recipient.each do |user|
      call_for_user user
    end
  end

  # you may need to call it manually to solve #167434851
  def self.call_for_user(user)
    latest_momentum = MomentumHistoricValue.where(user: user).order(created_on: :desc).first
    momentum = user.momentum

    # no need to store same-momentum values because they don't look good on graphs
    # only dynamics is what's important
    return if latest_momentum.present? && latest_momentum.value == momentum

    mhv = MomentumHistoricValue.where(created_on: Date.today, user: user).first

    if mhv.present?
      mhv.value = user.momentum
      mhv.save!
    else
      MomentumHistoricValue.create! created_on: Date.today, user: user, value: user.momentum
    end
  end
end

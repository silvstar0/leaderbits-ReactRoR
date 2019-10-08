# frozen_string_literal: true

class VacationModePolicy < ApplicationPolicy
  def create?
    #TODO check unless has upcoming/ongoing vacation mode?
    true
  end

  def update?
    record.user == user && record.ends_at > Time.now
  end

  def destroy?
    update?
  end
end

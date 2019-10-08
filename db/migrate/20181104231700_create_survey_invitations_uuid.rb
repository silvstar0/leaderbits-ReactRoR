# frozen_string_literal: true

class CreateSurveyInvitationsUuid < ActiveRecord::Migration[5.2]
  def change
    add_column :survey_invitations, :uuid, :string, null: false, index: true
  end
end

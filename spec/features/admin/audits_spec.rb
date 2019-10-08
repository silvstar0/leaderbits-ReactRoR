# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Admin:Audits", type: :feature, js: true do
  describe '#index' do
    it 'displays destroyed users' do
      user = create(:system_admin_user)

      user2 = create(:user)
      login_as(user, scope: :user, run_callbacks: false)

      visit admin_user_path(user2)
      page.accept_confirm do
        click_link 'Destroy'
      end
      expect(page).to have_content("User successfully destroyed")

      #NOTE: this won't work anymore:
      #Audited.audit_class.as_user(@user) do
      #  user.destroy
      #end

      visit admin_audits_path

      expect(page).to have_content("User(##{user2.id})")
      expect(page).to have_content("destroy")
    end

    pending 'displays new created user'
    pending 'displays modified user'
  end
end

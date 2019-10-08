# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActiveSupport::Notifications for users for intercom sync' do
  include ActiveJob::TestHelper

  example 'for new user' do
    user = create(:user)

    expect(IntercomContactSyncJob).to have_been_enqueued.with(user.id)
  end

  example 'whenever user is updated' do
    user = create(:user)

    clear_enqueued_jobs

    expect(IntercomContactSyncJob).not_to have_been_enqueued.with(user.id)

    user.name = 'John'
    user.save!

    expect(IntercomContactSyncJob).to have_been_enqueued.with(user.id)
  end
end

# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include AdminOrdering
    include ActsAsUnobtrusiveFlash
    before_action :authenticate_user!

    skip_after_action :intercom_rails_auto_include

    layout 'admin'

    before_action :set_proper_audited_status

    def set_proper_audited_status
      Audited.auditing_enabled = true
    end
  end
end

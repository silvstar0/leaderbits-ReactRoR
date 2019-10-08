# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.mailer_default_from
  layout 'mailer'
end

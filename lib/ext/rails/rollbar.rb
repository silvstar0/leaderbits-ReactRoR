# frozen_string_literal: true

# ext file to keep base user model simple
Rails.application.config.to_prepare do
  #:nocov:
  User.class_eval do
    #the reason why it became a separate method is because Rollbar config doesn't accept lambda for person_email_method option
    def rollbar_person_email_method
      name
    end
  end
  #:nocov:
end

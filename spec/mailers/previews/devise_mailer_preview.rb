# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/devise_mailer
class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    user = User.new(name: [Faker::Name.first_name, nil].sample, email: Faker::Internet.email)
    Devise::Mailer.reset_password_instructions user, 'dummy-token'
  end
end

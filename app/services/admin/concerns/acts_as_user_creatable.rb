# frozen_string_literal: true

module Admin
  module ActsAsUserCreateable
    # @return [User]
    def before_validate(user, _input)
      def user.password_required?
        false
      end
      user
    end

    # @return [User]
    def after_save(user, input)
      LeaderbitsEmployee.where(user: user).delete_all
      LeaderbitEmployeeMentorship.where(mentor_user: user).delete_all

      #> input[:user][:employee_in_organization]
      #=> <ActionController::Parameters {"6"=>"on", "12"=>"on", "3"=>"on", "5"=>"on", "22"=>"on", "13"=>"on", "9"=>"on", "14"=>"on", "1"=>"on", "10"=>"on", "2"=>"on", "19"=>"on", "23"=>"on", "15"=>"on"} permitted: false>
      Array(input.dig(:user, :employee_in_organization)).each do |organization_id, _on_string|
        organization = Organization.find organization_id

        LeaderbitsEmployee.create! organization: organization, user: user
      end

      #> input[:user][:employee_in_organization]
      #=> <ActionController::Parameters {"6"=>"on", "12"=>"on", "3"=>"on", "5"=>"on", "22"=>"on", "13"=>"on", "9"=>"on", "14"=>"on", "1"=>"on", "10"=>"on", "2"=>"on", "19"=>"on", "23"=>"on", "15"=>"on"} permitted: false>
      Array(input.dig(:user, :employee_mentor)).each do |mentee_user_id, _on_string|
        LeaderbitEmployeeMentorship.create! mentee_user: User.find(mentee_user_id), mentor_user: user
      end

      user
    end

    def user_attributes(input)
      attrs = [
        'employee_in_organization',
        'employee_mentor',
        #TODO-High is this "role" attribute still needed? looks like an artefact
        'role',
      ]

      input.fetch(:user).without(*attrs).yield_self do |user_params|
        #if user_params[:password].blank?
        #  user_params.delete(:password)
        #  user_params.delete(:password_confirmation)
        #end
        user_params
      end
    end
  end
end

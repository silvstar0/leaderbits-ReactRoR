# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      #NOTE: it is uuid string rather than User instance
      self.current_user = cookies.signed[:uuid]
    end
  end
end

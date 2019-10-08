# frozen_string_literal: true

class UnobtrusiveFlashMultiFormatWrapper
  # @param [ActionDispatch::Flash::FlashHash] original instance
  def initialize(flash)
    @flash = flash
  end

  # TODO-low add docs, clean up and refactore
  def set_after_js_redirect_flash_message(session, message)
    session[:after_js_redirect_flash_message] = message
  end

  # TODO-low add docs, clean up and refactore
  def fetch_flash_message_from_session_if_present(session)
    message = session[:after_js_redirect_flash_message]
    if message.present?

      regular type: :notice, message: message
      session.delete(:after_js_redirect_flash_message)
    end
  end

  # @example usage
  # > unobtrusive_flash.regular type: :notice, message: "hello world"
  #   is equivalent to default native *flash[:notice] = "Hello world"*
  def regular(type:, message:)
    @flash[type.to_sym] = message
  end

  # unobtrusive_flash.regular_now type: :notice, message: "hello worldnow"
  def regular_now(type:, message:)
    @flash.now[type.to_sym] = message
  end

  # @example usage
  # > unobtrusive_flash.achievement id: Rails.configuration.achievements.first_completed_challenge
  # NOTE: keep in sync with shared/footer_debug
  def achievement(id:)
    @flash["achievement|#{id}"] = :anything_really
  end

  # @example usage
  # > unobtrusive_flash.notify jquery_selector_name: "##{ ActionView::RecordIdentifier.dom_id(@entry) }",
  #                            class_name: 'success',
  #                            position: 'top',
  #                            message: "You earned #{@current_user.points.last.value} points for this entry. Keep it up you have #{current_user.total_points } points!"
  def notify(jquery_selector_name:, class_name:, position:, message:)
    @flash["notify|#{class_name}|#{jquery_selector_name}|#{position}"] = message
  end
end

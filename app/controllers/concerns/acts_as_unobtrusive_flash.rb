# frozen_string_literal: true

module ActsAsUnobtrusiveFlash
  extend ActiveSupport::Concern

  included do
    after_action :prepare_unobtrusive_flash
  end

  # @return [UnobtrusiveFlashMultiFormatWrapper] instance
  def unobtrusive_flash
    UnobtrusiveFlashMultiFormatWrapper.new(flash)
  end
end

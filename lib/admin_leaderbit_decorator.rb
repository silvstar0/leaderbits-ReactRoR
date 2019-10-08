# frozen_string_literal: true

class AdminLeaderbitDecorator < SimpleDelegator
  include ApplicationHelper
  include ActionView::Helpers
  include ActionView::Helpers::AssetTagHelper

  def description
    desc
  end

  def actual_image
    video_cover __getobj__
  end
end

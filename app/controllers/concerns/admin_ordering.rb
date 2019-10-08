# frozen_string_literal: true

module AdminOrdering
  extend ActiveSupport::Concern

  included do
    helper_method :order_by_direction
  end

  def order_by_direction(attribute)
    order_by[:attribute] == attribute ? order_by[:direction] : nil
  end

  def order_by
    if params[:order] && params[:direction]
      {
        attribute: params[:order],
        direction: params[:direction],
        value: "#{params[:order]} #{params[:direction].upcase}"
      }

    else
      { attribute: 'id', direction: 'desc', value: { id: :desc } }
    end
  end
end

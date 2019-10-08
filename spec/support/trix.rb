# frozen_string_literal: true

module TrixHelpers
  def fill_in_trix_editor(id, with:)
    find(:xpath, "//trix-editor[@input='#{id}']").click.set(with)
  end

  def find_trix_editor(id)
    find(:xpath, "//*[@id='#{id}']", visible: false)
  end
end

RSpec.configure do |c|
  c.include TrixHelpers, type: :feature
end

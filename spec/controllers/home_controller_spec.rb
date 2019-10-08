# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController do
  describe "GET /robots.txt" do
    let(:robots_txt_content) {
      <<~CONTENT.strip_heredoc
        User-Agent: *
        Disallow: /
      CONTENT
    }

    before do
      # TODO delete in after block or add to gitignore
      File.open(Rails.root.join("config/robots.#{Rails.env}.txt"), 'w') { |f| f.write(robots_txt_content) }
    end

    it "returns valid content" do
      get :robots

      expect(response).to be_successful
      expect(response.body).to eq(robots_txt_content)
    end
  end
end

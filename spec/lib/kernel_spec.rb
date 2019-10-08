# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Kernel do
  describe '#all_global_tag_labels' do
    example do
      leaderbit = create(:leaderbit)
      question = create(:slider_question)

      create(:leaderbit_tag, label: 'Circus', leaderbit: leaderbit)
      %w(Bowling Saxophone Video Walking).shuffle.each do |label|
        factory_name = %i[question_tag leaderbit_tag].sample
        case factory_name
        when :question_tag
          create(factory_name, label: label, question: question)
        when :leaderbit_tag
          create(factory_name, label: label, leaderbit: leaderbit)
        else
          raise factory_name.to_s
        end
      end
      create(:question_tag, label: 'Circus', question: question)

      expect(all_global_tag_labels).to eq(["Bowling", "Circus", "Saxophone", "Video", "Walking"])
    end
  end
end

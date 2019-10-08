# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntryReplyMailer do
  let(:leaderbit) { create(:leaderbit) }
  let!(:entry) { create(:entry, discarded_at: nil, user: create(:user, email: 'entry_author@email.com', name: 'entry author'), leaderbit: leaderbit) }

  describe "another user replied to my entry" do
    let(:entry_author) { entry.user }
    let(:user2) { create(:user) }
    let!(:entry_reply) { create(:entry_reply, entry: entry, user: user2) }

    example do
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.to).to contain_exactly(entry_author.email)
      expect(mail.subject).to eq("#{user2.name} Replied to You - #{leaderbit.name}")
    end
  end

  describe "one mentor replied to another mentor" do
    let(:entry_author) { entry.user }

    let(:entry_reply1) { create(:entry_reply, user: create(:user, email: 'reply1.author@email.com', name: 'reply1 author'), entry: entry) }
    let(:entry_reply2) { create(:entry_reply, user: create(:user, email: 'reply2.author@email.com', name: 'reply2 author'), entry: entry, parent_reply_id: entry_reply1.id) }

    example do
      entry_reply1
      ActionMailer::Base.deliveries = []

      entry_reply2
      expect(ActionMailer::Base.deliveries.size).to eq(2)

      mail1 = ActionMailer::Base.deliveries[0]

      expect(mail1.to).to contain_exactly(entry_reply2.parent_entry_reply.user.email)
      expect(mail1.subject).to eq("reply2 author Replied to You - #{leaderbit.name}")

      # copy notification to original entry author
      mail2 = ActionMailer::Base.deliveries[1]
      expect(mail2.to).to contain_exactly(entry_reply2.parent_entry_reply.entry.user.email)
      expect(mail2.subject).to eq("reply2 author Replied - #{leaderbit.name}")
    end
  end
end

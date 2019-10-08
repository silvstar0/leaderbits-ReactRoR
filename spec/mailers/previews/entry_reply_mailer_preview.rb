# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/leaderbit_mailer
class EntryReplyMailerPreview < ActionMailer::Preview
  def new_reply_to_entry_with_like
    skip_bullet do
      entry_reply = EntryReply
                      .where(parent_reply_id: nil)
                      .shuffle
                      .detect { |reply| reply.entry.get_likes.count > 0 } || raise

      subject = "#{entry_reply.user.name} Replied to You - #{entry_reply.entry.leaderbit.name}"
      EntryReplyMailer
        .with(entry_reply: entry_reply, email_recipient_user: entry_reply.entry.user, subject: subject)
        .new_reply
    end
  end

  def new_reply_to_entry_without_like
    skip_bullet do
      entry_reply = EntryReply
                      .where(parent_reply_id: nil)
                      .shuffle
                      .detect { |reply| !reply.user.favorited?(reply.entry) } || raise

      subject = "#{entry_reply.user.name} Replied to You - #{entry_reply.entry.leaderbit.name}"
      EntryReplyMailer
        .with(entry_reply: entry_reply, email_recipient_user: entry_reply.entry.user, subject: subject)
        .new_reply
    end
  end

  def new_reply_to_reply
    skip_bullet do
      entry_replies = EntryReply.where.not(parent_reply_id: nil)
      entry_reply = entry_replies
                      .select { |er| Rails.env.production? ? true : er.content.include?("http") } #testing how replies with links look(in production we don't currently have such replies)
                      .sample || raise

      subject = "#{entry_reply.user.name} Replied to You - #{entry_reply.entry.leaderbit.name}"
      EntryReplyMailer
        .with(entry_reply: entry_reply, email_recipient_user: entry_reply.parent_entry_reply.user, subject: subject)
        .new_reply
    end
  end
end

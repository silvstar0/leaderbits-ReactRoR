# frozen_string_literal: true

class AddFirstLeaderBitTextToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :introducing_leaderbits_to_team, :text, default: "Hi Team,

    I’m writing to let you know we’ve started a technical leadership program called LeaderBits.

    I know there are many great people at BIMobject and some desire a path to leadership as we continue to grow.

    LeaderBits is a way for me to resource you with leadership content. The system sends out small bits of leadership in short 2-5min videos over time.

    When you engage with the content you level up, learn, and gain experience as a leader. I see metrics on how you engage with the system and your ReflectDB entries. LeaderBits is for those of you who want to grow as a leader hear at BIMobject.

    Ben O'Donnell

    P.S. Please whitelist team@leaderbits.io to ensure you receive the LeaderBits."
  end
end

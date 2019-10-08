# frozen_string_literal: true

class VisibleToFieldsCleanup < ActiveRecord::Migration[5.2]
  def change
    change_column_default :entries, :visible_to_my_mentors, false
    change_column_default :entries, :visible_to_my_peers, false
    change_column_default :entries, :visible_to_community_anonymously, false

    change_column_null :entries, :visible_to_my_mentors, false
    change_column_null :entries, :visible_to_my_peers, false
    change_column_null :entries, :visible_to_community_anonymously, false
  end
end

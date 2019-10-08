# frozen_string_literal: true

#is separate class necessary? Not sure but keeping as big method on User class doesn't add much readability

class LikedMessageGenerator
  def initialize(votable)
    @votable = votable
  end

  # @return [String] display message how it looks for user - keep in mind that if user liked himself, message is different than for others
  def return_for_user(user)
    #TODO-low optimize further? we can probaly replace #name and user instantiating with just first_name & last_name fetching instead
    voted_display_names = Rails.cache.fetch("#{@votable.cache_key_with_version}/voter-display-names") {
      ActsAsVotable::Vote
        .where(votable: @votable, vote_flag: true)
        .includes(:voter)
        .yield_self(&method(:same_organization_voter_of_from_leaderbits_organization_clause))
        .collect(&:voter)
        .collect(&:name)
    }
                            .without(user.name) # current_user is displayed because in this case "Like" is in bold and that's enough
                            .without(@votable.user.name)

    return '' if voted_display_names.blank?

    resource_name = @votable.class.to_s.downcase.gsub('entryreply', 'reply')
    voted_display_names
      .to_sentence
      .yield_self { |authors| "#{authors} liked this #{resource_name}" }
  end

  private

  def same_organization_voter_of_from_leaderbits_organization_clause(relation)
    query = <<-SQL.squish
      voter_id IN(SELECT id FROM users WHERE organization_id = ?)
        OR voter_id IN(SELECT users.id FROM users INNER JOIN organizations ON users.organization_id = organizations.id WHERE organizations.name IN(?))
    SQL

    relation
      .where(query, @votable.user.organization_id, official_leaderbits_org_names)
  end
end

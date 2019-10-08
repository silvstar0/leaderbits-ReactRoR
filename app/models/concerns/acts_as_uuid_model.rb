# frozen_string_literal: true

# @Usage understand the nuances of how friendly id finding works to avoid security/privacy issues
# User.friendly.find_by_friendly_id 1 # raises
# User.friendly.find_by_friendly_id uuid # finds
#
# User.friendly.find 1 # finds
# User.friendly.find uuid # finds
#
# or just use User.find_by_uuid uuid
module ActsAsUuidModel
  extend ActiveSupport::Concern

  included do
    include FriendlyId
    friendly_id :uuid, use: :slugged, slug_column: :uuid

    before_create :set_uuid_key
  end

  private

  def set_uuid_key
    self.uuid = generate_uuid
  end

  def generate_uuid
    loop do
      # 7-level uuid as requested by Joel
      token = SecureRandom.hex[0..6]
      break token unless self.class.where(uuid: token).exists?
    end
  end
end

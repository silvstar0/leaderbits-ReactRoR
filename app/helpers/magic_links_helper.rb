# frozen_string_literal: true

module MagicLinksHelper
  # @return [String] e.g. "j**l@twitter.com"
  def masked_email(user)
    handle, domain = user.email.split('@')

    case handle.length
    when 1
      return "*@#{domain}"
    when 2
      return "*#{handle[-1]}@#{domain}"
    end

    [
      handle[0],
      "*" * (handle.length - 2),
      handle[-1],
      "@",
      domain
    ].join('')
  end
end

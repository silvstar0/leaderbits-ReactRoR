# frozen_string_literal: true

# This is needed because Bullet is only available in development
# but mailer previews are present in staging as well
#
# The reason why Bullet is disabled in mailer previews is because there is not much you can preload for individual mailer action
# and existing warnings are hard to fix and very annoying
if defined?(Bullet)
  def skip_bullet
    previous_value = Bullet.enable?
    Bullet.enable = false
    yield
  ensure
    Bullet.enable = previous_value
  end
else
  def skip_bullet
    yield
  end
end

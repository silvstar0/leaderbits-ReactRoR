# frozen_string_literal: true

# The reason why it is disabled in initializer is because we need to skip it everywhere except places where we
# explicitely enabled audit(admin actions)
# All services, CRON tasks must have auditing disabled
Audited.auditing_enabled = false

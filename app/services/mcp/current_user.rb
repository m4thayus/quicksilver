# frozen_string_literal: true

module Mcp
  # Resolves the per-connection identity supplied via the
  # X-Quicksilver-User-Email header into a User. Isolating all identity logic
  # here means a future migration to per-engineer tokens only has to change how
  # the user is derived (e.g. from the bearer token) without touching handlers.
  class CurrentUser
    attr_reader :email, :user

    def initialize(email:)
      @email = email.presence
      @user = User.find_by(email: @email) if @email
    end

    def resolved?
      user.present?
    end

    def engineer_or_admin?
      resolved? && (user.engineer? || user.admin?)
    end
  end
end

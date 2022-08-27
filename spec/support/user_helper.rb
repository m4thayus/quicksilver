# frozen_string_literal: true

module UserHelper
  def self.for_role(role)
    case role
    when :admin
      FactoryBot.create(:admin_user)
    when :engineer
      FactoryBot.create(:engineer_user)
    end
  end

  def self.credentials(user, password = user.password)
    { email: user.email, password: password }
  end
end

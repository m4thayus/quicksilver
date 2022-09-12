# frozen_string_literal: true

module UserHelper
  def self.for_role(role)
    FactoryBot.create(*Array.wrap(role))
  end

  def self.credentials(user, password = user.password)
    { email: user.email, password: }
  end

  def login_as(user_selector, password: nil)
    user = if user_selector.is_a? Symbol
             UserHelper.for_role(user_selector)
           elsif user_selector.acts_like? :string
             build(:user, email: user_selector)
           else
             user_selector
           end
    user.password = password if password.present?

    visit login_path
    fill_in "email", with: user.email
    fill_in "password", with: user.password
    click_button "Login"
  end

  def logout
    visit logout_path
  end
end

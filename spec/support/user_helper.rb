# frozen_string_literal: true

module UserHelper
  def self.for_role(role)
    FactoryBot.create(*Array.wrap(role))
  end

  def self.credentials(user, password = user.password)
    { email: user.email, password: }
  end

  def login_as(user, password: user.password)
    email = if user.acts_like? :string
              User.find_by(email: user)&.email || user
            else
              user.email
            end

    visit login_path
    fill_in "email", with: email
    fill_in "password", with: password
    click_button "Login"
  end

  def logout
    visit logout_path
  end
end

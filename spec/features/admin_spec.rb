# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin", type: :feature do
  before do
    login_as UserHelper.for_role(:admin_user)
  end

  it "can edit any user"
end

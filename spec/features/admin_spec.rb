# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin", type: :feature do
  before do
    login_as :admin_user
  end

  it "can edit any user"
end

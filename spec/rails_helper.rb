# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join("spec/fixtures").to_s]
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:each, type: :request) do |example|
    next unless example.metadata.key?(:user)

    role = example.metadata[:user]
    current_user = UserHelper.for_role(role)
    post "/login", params: { user: UserHelper.credentials(current_user) } if current_user.present?
  end

  config.include ViewUserHelper, type: :view
  config.include UserHelper, type: :feature

  config.before(:each, type: :view) do |example|
    without_verifying_partial_doubles do
      role = example.metadata[:user]
      current_user = UserHelper.for_role(role) if role
      allow(controller).to receive(:current_user).and_return(current_user)
    end
  end
end

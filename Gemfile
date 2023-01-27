# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version")

gem "rails", "~> 7.0.4", ">= 7.0.4.1"

gem "sqlite3", "~> 1.4" # NOTE: Default rails minimum version requirement

gem "puma", "~> 5.0" # NOTE: Default rails minimum version requirement

gem "jsbundling-rails"
gem "slim-rails"
gem "sprockets-rails"
gem "sassc-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7" # NOTE: Default rails minimum version requirement

gem "cancancan"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

gem "redcarpet"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem "digest", "3.1.0" # remove this when github action isn't broken

group :production do
  gem "strscan", "3.0.1" # remove this when passenger isn't broken
end

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "launchy"

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "rspec-rake", require: false
end

group :development do
  gem "spring"

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "slim_lint", require: false

  # Run linting and spec Git hooks
  gem "lefthook"

  # Static analysis tool to check for security vulnerabilities
  gem "brakeman"

  # Patch-level verification for bundler
  gem "bundler-audit"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  gem "capistrano"
  gem "capistrano-rbenv"
  gem "capistrano-bundler"
  gem "capistrano-rails"
  gem "capistrano-passenger"
  gem "capistrano-yarn"
  gem "ed25519", ">= 1.2", "< 2.0"
  gem "bcrypt_pbkdf", ">= 1.0", "< 2.0"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"

  gem "database_cleaner-active_record"

  gem "webmock"
  gem "timecop"
end

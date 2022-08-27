# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }
  config.before { DatabaseCleaner.strategy = :transaction }
  config.before(:each, js: true) { DatabaseCleaner.strategy = :truncation }

  config.around do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end

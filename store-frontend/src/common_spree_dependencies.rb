# By placing all of Spree's shared dependencies in this file and then loading
# it for each component's Gemfile, we can be sure that we're only testing just
# the one component of Spree.
source 'https://rubygems.org'

gem 'ddtrace'
gem 'sass-rails'
gem 'sqlite3', '~> 1.4.0', platforms: [:ruby, :mingw, :mswin, :x64_mingw]
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]


platforms :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbcsqlite3-adapter'
end

platforms :ruby do
  gem 'mysql2'
  gem 'pg', '~> 0.18'
end

group :test do
  gem 'capybara', '~> 3.24'
  gem 'capybara-screenshot', '~> 1.0'
  gem 'database_cleaner', '~> 1.3'
  gem 'email_spec'
  gem 'factory_bot_rails', '~> 5.0'
  gem 'rspec-activemodel-mocks', '~> 1.0'
  gem 'rspec-rails', '~> 4.0.0.beta2'
  gem 'rspec-retry'
  gem 'rspec_junit_formatter'
  gem 'jsonapi-rspec'
  gem 'simplecov'
  gem 'webmock', '~> 3.0.1'
  gem 'timecop'
  gem 'rails-controller-testing'
end

group :test, :development do
  gem 'rubocop', '~> 0.60.0', require: false
  gem 'rubocop-rspec', require: false
  gem 'pry-byebug'
  gem 'webdrivers', '~> 4.0.0'
end

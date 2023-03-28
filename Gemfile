source "https://rubygems.org"

gemspec

gem 'pry'
gem 'simplecov', require: false, group: :test

install_if -> { ENV.fetch('RAILS_VERSION', nil) } do
  rails_version = ENV.fetch('RAILS_VERSION', nil)
  gem 'actionpack', rails_version
  gem 'activesupport', rails_version
end

source 'https://rubygems.org'

gemspec

# Bundle edge Rails instead:
gem 'rails'
gem 'thin'
gem 'sqlite3'
gem 'mysql2'
gem 'rspec-rails'
gem 'rspec_candy' # for extra fun testing helpers

# http://stackoverflow.com/questions/8395347/gollum-wiki-undefined-method-new-for-redcarpetmodule
gem 'redcarpet', '1.17.2' # for markdown support

group :development, :test do
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-rspec'
  gem 'guard-livereload'
end

gem 'activerecord-import', :git => 'git://github.com/zdennis/activerecord-import.git'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

source 'https://rubygems.org'

gemspec

#gem 'rails'#, '~> 4.2.11.3'

# Make common databases all work
#gem 'sqlite3' # base reset
#gem 'mysql2' # TODO: first/works i believe
gem 'pg' # TODO - best case

group :development, :test do
  gem 'rspec' #-rails' # TODO: just 'rspec'
  gem 'rspec_candy' 
end

gem 'activerecord-import', :git => 'git://github.com/zdennis/activerecord-import.git'

group :assets do
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier'#, '>= 1.0.3'
end

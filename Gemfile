source 'https://rubygems.org'

gemspec

gem 'rails'#, '~> 4.2.11.3'

# Make common databases all work
#gem 'sqlite3' # base reset
#gem 'mysql2' # TODO: first/works i believe
gem 'pg' # TODO - best case

group :development, :test do
  gem 'rspec-rails'#, "~> 3"
  #gem 'rspec_candy' # for extra fun testing helpers # TODO: needed
end

gem 'activerecord-import', :git => 'git://github.com/zdennis/activerecord-import.git'

group :assets do
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier'#, '>= 1.0.3'
end

# TODO: Below For presentation/not important
# http://stackoverflow.com/questions/8395347/gollum-wiki-undefined-method-new-for-redcarpetmodule
#gem 'redcarpet'#, '1.17.2' # for markdown support 
#gem "googlecharts"


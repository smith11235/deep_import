#require 'bundler/setup'
#Bundler.setup

# Switch from PG to MYSQL / ETC
#def change_database_connection( config_name )
#	puts "Setting db to #{config_name}"
#	ActiveRecord::Base.establish_connection( config_name )
#end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'deep_import'
require 'rspec_candy/all'

RSpec.configure do |config|
  # Until better setup - do not run Setup/Teardown
  config.filter_run_excluding manual: true 

  # Execute specific seed: --seed 1234
  config.order = "random"

  config.use_transactional_fixtures = true
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
end

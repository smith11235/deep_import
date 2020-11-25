require 'bundler/setup'
Bundler.setup

# Switch from PG to MYSQL / ETC
#def change_database_connection( config_name )
#	puts "Setting db to #{config_name}"
#end

# This file is copied to spec/ when you run 'rails generate rspec:install'
#ENV["RAILS_ENV"] ||= 'test'
#require File.expand_path("../../config/environment", __FILE__)
#require 'rspec/rails'
require 'deep_import'
require 'rspec_candy/all'
require 'pg'

require "support/models" 
# ^ Application + DeepImport Models
# TODO: move db/ files to spec/support/db

ENV["RAILS_ENV"] = "test"

def clean_db
  GrandChild.delete_all
  Child.delete_all
  Parent.delete_all
end

RSpec.configure do |config|
  # Until better setup - do not run Setup/Teardown
  # rspec --tag manual
  # rspec --tag timing
  config.filter_run_excluding manual: true, timing: true

  # Execute specific seed: --seed 1234
  config.order = "random"

  config.before(:suite) do
    ENV["DEEP_IMPORT_LOG_LEVEL"] ||= "FATAL"
    DeepImport.initialize! # uses config/deep_import.rb - use: $deep_import_config

    # TODO: make this ENV[DATABASE_URL] var
    ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      database: :deep_import_test,
      username: :railsapp,
      password: '5aed99058d873716ebec7111b2e679dc',
      host: "dri9edszt4r0qb.carwfspvbpap.us-east-1.rds.amazonaws.com",
      port: 5432
    )
  end

  # TODO: simplify/whats missing with DatabaseCleaner/etc
  config.before(:each) do
    clean_db
  end
  #config.after(:each) do
  #  clean_db
  #end

end

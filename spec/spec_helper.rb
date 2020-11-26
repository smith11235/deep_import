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

support_dir = File.join( File.dirname( File.expand_path( __FILE__ ) ), "support" )
DEEP_IMPORT_CONFIG = ENV["DEEP_IMPORT_CONFIG"] || File.join(support_dir, "config/deep_import.yml")

def clean_db
  GrandChild.delete_all
  Child.delete_all
  Parent.delete_all
end

RSpec.configure do |config|
  ### Some Tests Excluded From General Exectution
  # -----------
  # To run Benchmark tests/examples
  # rspec --tag timing 

  # To test Setup/Teardown logic (add/remove db migrations)
  # rspec --tag manual  # TODO: rename db
  config.filter_run_excluding manual: true, timing: true
  # ==========

  # Execute specific seed: --seed 1234
  config.order = "random"

  config.before(:suite) do
    support_dir = File.join( File.dirname( File.expand_path( __FILE__ ) ), "support" )
    ENV["DEEP_IMPORT_CONFIG"] ||= DEEP_IMPORT_CONFIG
    ENV["DEEP_IMPORT_LOG_LEVEL"] ||= "FATAL"
    DeepImport.initialize! # uses config/deep_import.rb - use: $deep_import_config

    conn = {}
    YAML.load_file("database.yml").each {|k, v| conn[k.to_sym] = v}
    ActiveRecord::Base.establish_connection(conn)
  end

  config.before(:each) do
    # TODO: use DatabaseCleaner
    clean_db
  end

end

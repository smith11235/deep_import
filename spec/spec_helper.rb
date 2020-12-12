require 'bundler/setup'
Bundler.setup

require 'deep_import'
require 'rspec_candy/all'
require 'pg'

require "support/models" 
# ^ Application + DeepImport Models

def clean_db
  # TODO: use DatabaseCleaner
  InLaw.delete_all
  GrandChild.delete_all
  Child.delete_all
  Parent.delete_all
end

RSpec.configure do |config|
  ### Some Tests Excluded From General Exectution
  # -----------
  # To run Benchmark tests/examples
  # rspec --tag timing  # TODO: rename 'benchmark'

  # To test Setup/Teardown logic (add/remove db migrations)
  # rspec --tag manual  # TODO: rename 'migration'
  config.filter_run_excluding manual: true, timing: true

  # Execute specific seed: --seed 1234
  config.order = "random"

  config.before(:suite) do
    ENV["DEEP_IMPORT_LOG_LEVEL"] ||= "FATAL" # minimal log output by default
    DeepImport.set_db_connection_for_development!
  end

  config.before(:each) do
    clean_db
  end

end

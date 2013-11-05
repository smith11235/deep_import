export RAILS_ENV=development
bundle exec rake deep_import:teardown && rake db:drop && rake db:create && rake db:migrate && rake deep_import:setup

namespace :deep_import do 
  # Note: Works in Rails only

  desc "Create DeepImport migration for database"
  task setup: :environment do 
    DeepImport::Migration.create_file
  end

  desc "Remove DeepImport migration"
  task teardown: :environment do 
    DeepImport::Migration.remove_file
  end

end

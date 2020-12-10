namespace :deep_import do 
  def migrate_command(direction) # up or down
    task = []
    gem_development = DeepImport.db_root_path.start_with?("spec/support") # Development?
    task << "deep_import_development" if gem_development
    task << "db:migrate"

    version = deep_import_migration_version # get the file we want to remove 
    task << "#{direction} VERSION=#{version}" if direction == 'down'

    task = task.join(":")
    "rake #{task}"
  end

  desc "Create/Refresh DeepImport model and database modifications based on config/deep_import.yml"
  task :setup do 
    ENV["deep_import_disable_railtie"] = "1" # TODO: necessary? can this be removed
    DeepImport::Setup.new
    DeepImport.logger.info "DeepImport: Setup: Load Schema Changes:\nRun: '#{migrate_command('up')}'".green
  end

  desc "Remove DeepImport model and database modifications"
  task :teardown do 
    version = deep_import_migration_version # get the file we want to remove 
    if version.nil?
      DeepImport.logger.info "DeepImport: Teardown: No migration file to remove.".green
      exit
    end
    DeepImport.logger.info "DeepImport: Teardown: Removing migration version: #{version}".yellow

    # Confirm deep import db components removed before removing migration file
    still_in_db = File.foreach(DeepImport.db_schema_file).grep(/\s"deep_import_.+/) 
    # TODO: check if migration is in database still...
    # - requires db connection - more complicated, maybe only if rails
    # - ActiveRecord::SchemaMigration.where(version: version).exists?
    if still_in_db
      raise "DeepImport: Schema changes still in DB, cannot remove migration file.\nRun: '#{migrate_command('down')}'".red
      # TODO: add development migrate:down task
      # otherwise, for development
      # drop, delete schema, then teardown, setup, migrate - messy
    end

    DeepImport::Teardown.new # removes generated files
  end

  def deep_import_migration_version
    migration = DeepImport.current_migration_file
    return nil if migration.nil?
    migration[/\d{14}/] # get the timestamp of this migration
  end

end

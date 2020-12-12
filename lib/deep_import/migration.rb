module DeepImport
  class Migration
    def self.current_file
      Dir.glob(DeepImport.migration_file_search).first
    end

    def self.migration_version
      migration = current_file
      return nil if migration.nil?
      migration[/\d{14}/] # get the timestamp of this migration
    end

    def self.create_file
      DeepImport::Setup.new
      DeepImport.logger.info "DeepImport: Setup: Load Schema Changes:\nRun: '#{migrate_command('up')}'".green
    end

    def self.remove_file
      version = migration_version # get the file we want to remove 
      if version.nil?
        raise "DeepImport: No migration file to remove (in: #{DeepImport.db_migrations_path})"
      end
      DeepImport.logger.info "DeepImport: Teardown: Removing migration version: #{version}".yellow
  

      # Confirm deep import db components removed before removing migration file
      still_in_db = File.exists?(DeepImport.db_schema_file) && File.foreach(DeepImport.db_schema_file).grep(/\s"deep_import_.+/) 
      # TODO: check if migration is in database still...
      # - requires db connection - more complicated, maybe only if rails
      # - ActiveRecord::SchemaMigration.where(version: version).exists?
      if still_in_db
        DeepImport.logger.fatal "Remove migration from DB: '#{migrate_command('down')}'".red
        raise "DeepImport: Schema changes still in DB, cannot remove migration file (#{DeepImport.db_schema_file})"
        # TODO: add development migrate:down task
        # otherwise, for development
        # drop, delete schema, then teardown, setup, migrate - messy
      end
  
      migration = current_file
      FileUtils.rm(migration)
      DeepImport.logger.info "DeepImport: Removed migration: #{migration}".green
    end

    def self.migrate_command(direction) # up or down
      task = []
      gem_development = DeepImport.db_root_path.start_with?("spec/support") # Development?
      task << "deep_import_development" if gem_development
      task << "db:migrate"
  
      version = migration_version # get the file we want to remove 
      task << "#{direction} VERSION=#{version}" if direction == 'down'
  
      task = task.join(":")
      "rake #{task}"
    end
  end
end


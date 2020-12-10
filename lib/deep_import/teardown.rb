module DeepImport

  class Teardown

    def initialize
      remove_generated_files
    end

    def remove_generated_files
      migration = DeepImport.current_migration_file
      FileUtils.rm(migration)
      DeepImport.logger.info "DeepImport: Teardown: Removed migration: #{migration}".green
    end

  end
end


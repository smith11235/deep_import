module DeepImport
  require 'digest/md5'

  class Setup

    def initialize
      @models = Config.importable

      no_current_migration_file! # TODO: Migration helper

      @lines = []
      base_model_changes
      add_deep_import_models

      write_migration_file

      DeepImport.logger.info "DeepImport: Created: #{migration_file}".green
      DeepImport.logger.info "DeepImport: ^ Add file to revision control.".green
    end

    private

    def no_current_migration_file! 
      migration = DeepImport::Migration.current_file
      return unless migration
      DeepImport.logger.fatal "Deep Import Migration Found: #{migration}\nTo reset/remove run: 'rake deep_import:teardown'".red
      # ^ TODO: run command should be dependent on if Rails defined
      raise "DeepImport: Migration already exists."
    end

    def md5(input)
      Digest::MD5.hexdigest(input)
    end

    def base_model_changes
      @models.each do |model_class|
        table_name = table_name_for(model_class)
        @lines << "add_column #{table_name}, :deep_import_id, :string, references: false"
        # hash is for postgres index name uniqueness requirements, and within max length limit
        @lines << "add_index #{table_name}, [:deep_import_id, :id], name: 'di_id_#{md5(table_name)}'"
      end
    end

    def add_deep_import_models
      @models.each do |model_class|
        add_deep_import_table(model_class, Config.belongs_to(model_class))
      end
    end

    def add_deep_import_table( model_class, belongs_to )
      table_name = table_name_for("DeepImport#{model_class}")
      @lines <<  "create_table #{table_name} do |t|"
      @lines <<  "  t.string :deep_import_id, references: false"
      @lines <<  "  t.datetime :parsed_at"
      @lines <<  "  t.timestamps"

      belongs_to.each do |belongs|
        rel = belongs.to_s.underscore.to_sym

        if Config.polymorphic(model_class).include?(rel)
          @lines <<  "  t.string :deep_import_#{rel}_id, references: false"
          @lines <<  "  t.string :deep_import_#{rel}_type, references: false"
        else # Standard, non polymorphic
          @lines <<  "  t.string :deep_import_#{rel}_id, references: false"
        end

      end

      @lines <<  "end"

      belongs_to.each do |belongs|
        rel = belongs.to_s.underscore.to_sym
        hash_of_source_target = md5( "#{table_name}_#{rel}" )
        # hash is for postgres index name uniqueness requirements
        index_name = "di_#{rel}_#{hash_of_source_target}"
        if Config.polymorphic(model_class).include?(rel)
          @lines <<  "add_index #{table_name}, [:deep_import_id, :deep_import_#{rel}_type, :deep_import_#{rel}_id], name: '#{index_name}'"
          @lines <<  "add_index #{table_name}, [:deep_import_#{rel}_type], name: '#{index_name}_type'"
        else
          @lines <<  "add_index #{table_name}, [:deep_import_id, :deep_import_#{rel}_id], name: '#{index_name}'"
        end
      end
    end

    def write_migration_file
      File.open(migration_file, "w") do |f|
        f.puts "class #{migration_name} < ActiveRecord::Migration#{rails_version}"
        f.puts "  def change"
        @lines.each do |line|
          f.puts "    #{line}"
        end

        f.puts "  end"
        f.puts "end"
      end
      raise "Failed to create migration file: #{migration_file}" unless File.file? migration_file
    end

    def rails_version
      # TODO: is this needed for non rails
      rails_version = defined?(Rails) ? Rails.version[/^\d.\d/] : "5.2"
      "[#{rails_version}]"
    end

    def table_name_for(model)
      # TODO: tableize
      ":#{model.to_s.underscore.pluralize}"
    end

    def migration_name
      @migration_name ||= DeepImport::MIGRATION_NAME
    end

    def migration_file
      @migration_file ||= File.join(
        DeepImport.db_migrations_path, 
        "#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{migration_name.underscore}.rb"
      )
    end

  end
end

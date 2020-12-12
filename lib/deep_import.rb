module DeepImport

  # TODO: Do I need to require these here? Or does bundler handle it
	require 'colorize'
  require 'active_support'
	require 'activerecord-import'

	deep_import_dir = File.join( File.dirname( File.expand_path( __FILE__ ) ), "deep_import" )

	%w( default_logger config migration setup import_options models_cache commit import importable saveable has_many belongs_to).each do |file|
		require File.join( deep_import_dir, file )
	end

  require 'deep_import/railtie' if defined?(Rails)

	mattr_accessor :logger

  @@logger = DeepImport.default_logger # stdout by default
  DeepImport.logger.level = ENV["DEEP_IMPORT_LOG_LEVEL"] || "INFO" # verbose by default

  def self.log_time(method, &block)
    # TODO: make fixed width output for spacing
    timing_at = 37
    prefix = "DeepImport.#{method}:"
    prefix = prefix.truncate(47)
    spacer = " " * (47 - prefix.size)
		DeepImport.logger.info "#{prefix.green}#{spacer}TIME: #{Benchmark.measure &block}"
  end

  def self.reset! # RSPEC helper
    import_options = nil 
    mark_ready_for_import!
	  DeepImport::ModelsCache.reset 
  end

	private 

	MIGRATION_NAME= "AddDeepImportEnhancements"
  READY=:ready_to_import
  IMPORTING=:importing

	mattr_reader :status

	@@status = READY 
	def self.status=( value )
		@@status = value
	end

	def self.mark_ready_for_import!
		DeepImport.status = READY
	end

	def self.ready_for_import?
		DeepImport.status == READY
	end

	def self.mark_importing!
		DeepImport.status = IMPORTING
	end

	def self.importing?
		DeepImport.status == IMPORTING
	end

  def self.config_file
    if db_root_path.start_with?("spec/support") # gem development
      "spec/support/config/deep_import.yml"
    else
      ENV["DEEP_IMPORT_CONFIG"] || "config/deep_import.yml" # custom location or rails config dir
    end
  end

  def self.db_root_path
    if defined?(Rails)
      "db"
    else
      ENV["DB_ROOT_PATH"] || # Non Rails Usage
        "spec/support/db" # gem development
    end
  end

  def self.db_schema_file
    File.join(db_root_path, "schema.rb")
  end

  def self.db_migrations_path
    File.join(db_root_path, "migrate")
  end

  def self.migration_file_search
    File.join(db_migrations_path, "*_#{MIGRATION_NAME.underscore}.rb")
  end

  def self.db_settings_for_development
    conn = {}
    YAML.load_file("database.yml").each {|k, v| conn[k.to_sym] = v}
    conn[:migrations_paths] = [db_migrations_path] 
    conn
  end

  def self.set_db_connection_for_development!
    ActiveRecord::Base.establish_connection(db_settings_for_development)
  end
end

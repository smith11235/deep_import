module DeepImport

  # TODO: Do I need to require these here? Or does bundler handle it
	require 'colorize'
  require 'active_support'
	require 'activerecord-import'

	deep_import_dir = File.join( File.dirname( File.expand_path( __FILE__ ) ), "deep_import" )

	%w( default_logger config initialize setup teardown import_options model_logic models_cache commit import ).each do |file|
		require File.join( deep_import_dir, file )
	end

  require 'deep_import/railtie' if defined?(Rails)

	mattr_accessor :logger

  @@logger = DeepImport.default_logger # stdout by default

  def self.log_time(method, &block)
    # TODO: make fixed width output for spacing
    timing_at = 37
    prefix = "DeepImport.#{method}:"
    prefix = prefix.truncate(47)
    spacer = " " * (47 - prefix.size)
		DeepImport.logger.info "#{prefix.green}#{spacer}TIME: #{Benchmark.measure &block}"
  end

	private 

	mattr_reader :status

	@@status = :uninitialized
	def self.status=( value )
		@@status = value
	end

	MIGRATION_NAME= "AddDeepImportEnhancements"
  READY=:ready_to_import
  IMPORTING=:importing

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

  def self.db_settings_for_development
    conn = {}
    YAML.load_file("database.yml").each {|k, v| conn[k.to_sym] = v}
    conn[:migrations_paths] = ["spec/support/db/migrate"]
    conn
  end

  def self.set_db_connection_for_development!
    ActiveRecord::Base.establish_connection(db_settings_for_development)
  end
end

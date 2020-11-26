module DeepImport

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

	mattr_accessor :settings 
	@@settings = { 
		:migration_name => "AddDeepImportEnhancements", 
		:required_status_for_import => :ready_to_import, 
		:enable_import_logic_status => :importing  
	}

	def self.mark_ready_for_import!
		DeepImport.status = DeepImport.settings[:required_status_for_import]
	end

	def self.ready_for_import?
		DeepImport.status == DeepImport.settings[:required_status_for_import]
	end

	def self.mark_importing!
		DeepImport.status = DeepImport.settings[:enable_import_logic_status] 
	end

	def self.importing?
		DeepImport.status == DeepImport.settings[:enable_import_logic_status] 
	end
end

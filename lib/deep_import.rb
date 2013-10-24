module DeepImport

	require 'colorize'
	require 'activerecord-import'

	mattr_accessor :logger
	mattr_reader :status
	@@status = :init
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

	# root code directory
	root = File.dirname( File.expand_path( __FILE__ ) )
	root = File.join root, "deep_import"

	%w( default_logger config initialize setup teardown import_options model_logic models_cache commit railtie import ).each do |file|
		require File.join( root, file )
	end

end

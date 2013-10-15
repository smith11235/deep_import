module DeepImport

	require 'colorize'
	require 'activerecord-import'

	mattr_accessor :logger # default to Rails.logger in railtie, can be set by user 
	mattr_accessor :status

	mattr_accessor :settings 
	@@settings = { :migration_name => "AddDeepImportEnhancements" }

	def self.importing?
		DeepImport.status == :importing
	end

	def self.after_initialization_disabled?
		! ENV["disable_deep_import"].nil?
	end

	# root code directory
	root = File.dirname( File.expand_path( __FILE__ ) )
	root = File.join root, "deep_import"

	%w( config setup teardown model_logic models_cache commit initializer railtie import ).each do |file|
		require File.join( root, file )
	end


end

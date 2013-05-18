module DeepImport

	require 'colorize'
	require 'activerecord-import'

	# root code directory
	root = File.dirname( File.expand_path( __FILE__ ) )
	root = File.join root, "deep_import"

	%w( config setup model_logic models_cache commit railtie ).each do |file|
		require File.join( root, file )
	end
end

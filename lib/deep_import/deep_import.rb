module DeepImport
	require 'colorize'
	require 'activerecord-import'
	require 'railtie' if defined?(Rails)

	root = File.expand_path( "../deep_import", File.dirname(__FILE__) )
	%w( config_parser setup after_initialize models_cache commit ).each do |file|
		require File.join( root, file )
	end
end

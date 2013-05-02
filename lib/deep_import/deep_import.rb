module DeepImport
	require 'colorize'
	require 'railtie' if defined?(Rails)

	root = File.expand_path( "../deep_import", File.dirname(__FILE__) )
	require File.join( root, "config_parser" )
end

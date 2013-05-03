namespace :deep_import do 

	desc "Create migrations based on config/deep_import.yml"
	task :setup => :environment do 
		puts "Welcome to DeepImport:".green
		config_file_path = File.join( Rails.root, "config", "deep_import.yml" )
		raise "Missing Config File: #{config_file_path}".red unless File.file? config_file_path
		config = YAML::load File.open( config_file_path )
		config_parser = DeepImport::ConfigParser.new( config )
		generate_statements = config_parser.tracking_model_generate_logic
		generate_statements.each do |model,statement|
			puts "rails generate model #{statement}"
		end
	end
end

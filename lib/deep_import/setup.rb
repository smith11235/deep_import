module DeepImport

	class Setup

		def initialize
			config_parser = DeepImport::ConfigParser.new
			@config = config_parser.deep_import_config
			setup_deep_import_generate_statements
			@timestamp = Time.now.utc.strftime( '%Y%m%d%H%M%S' )
			write_models_script( :destroy )
			write_models_script( :generate )
			puts "- Run the above generated shell script"
			puts "- rake db:migrate"
			puts "- Run the above destroy shell script to remove deep import"
		end

		def write_models_script( method )
			script_path = File.join Rails.root, "script", "#{@timestamp}_deep_import_#{method}.sh"
			puts "Writing: #{script_path}".yellow
			File.open( script_path, "w" ) do |f|
				@generate_statements.each do |statement|
					f.puts "rails #{method} #{statement}"
				end
			end
		end

		def new_model_string( name )
			"model DeepImport#{name} deep_import_id:string parsed_at:datetime"
		end

		def add_deep_import_id_migration_string( name )
			"migration AddDeepImportIdTo#{name.pluralize} deep_import_id:string"
		end

		def setup_deep_import_generate_statements
			generate_statements = Array.new
			@config[:models].each do |model_name,info|
				generate_statements << add_deep_import_id_migration_string( model_name )
				generate_statements << new_model_string( model_name )

				info[ :belongs_to ].each do |parent_class|
					deep_import_parent_name = "DeepImport#{parent_class}".underscore
					generate_statements.last << " " << deep_import_parent_name << "_id:string" unless generate_statements.last =~ /#{deep_import_parent_name}/ 
				end
			end
		  @generate_statements = generate_statements
		end

	end
end

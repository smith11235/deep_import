module DeepImport

	class Setup

		def initialize
			config_parser = DeepImport::ConfigParser.new
			@config = config_parser.deep_import_config
			setup_deep_import_generate_model_statements
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
				@generate_statements.each do |model,statement|
					f.puts "rails #{method} model #{statement}"
				end
			end
		end


		def setup_deep_import_generate_model_statements
			generate_statements = Hash.new
			@config[:roots].each do |root_name|
				generate_statements[ root_name ] = "Soft#{root_name} soft_id:integer"
			end

			@config[:models].each do |model_name,info|
				generate_statements[ model_name ] ||= "Soft#{model_name} soft_id:integer"

				info[ :belongs_to ].each do |parent_class|
					soft_parent_name = "Soft#{parent_class}".underscore
					generate_statements[ model_name ] << " " << soft_parent_name << ":references" unless generate_statements[ model_name ] =~ /#{soft_parent_name}/ 
				end
			end
		  @generate_statements = generate_statements
		end

	end
end

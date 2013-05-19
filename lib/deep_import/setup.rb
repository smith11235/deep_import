module DeepImport

	class Setup

		def initialize
			@config = Config.deep_import_config

			migrations_for_existing_models

			puts "- " + "git add .".red + "# to add all new generated migration and model files"
			puts "- " "rake db:migrate".red
		end

		def migrations_for_existing_models
			@config[:models].each do |model_class,info|
				plural_name = model_class.to_s.pluralize
				table_name = plural_name.underscore
				name = "AddDeepImportIdTo#{plural_name}"
				raise "Already a migration named: #{name}, suggest: rm db/migrate/*deep_import*" if Dir.glob( "db/migrate/*_#{name.underscore}.rb" ).size > 0
				create_migration( name ) do |f|
    			f.puts "      add_column :#{table_name}, :deep_import_id, :string"
					f.puts "      add_index :#{table_name}, [:deep_import_id, :id], :name => 'di_id_index'"
				end
			end
		end

		def create_migration( name )
			sleep( 1 ) # ensure unique timestamp
			migration_file = "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{name.underscore}.rb"
			File.open( migration_file, "w" ) do |f|
				f.puts "class #{name} < ActiveRecord::Migration"
				f.puts "  def change"
				yield f
				f.puts "  end"
				f.puts "end"
			end
			puts "Generated: #{migration_file}".green
		end

		def generate_index_migrations
			@config[:models].each do |model_class,info|
				plural_name = model_class.to_s.pluralize
				table_name = plural_name.underscore

				create_migration( "AddDeepImportIdIndexTo#{plural_name}" ) do |f|
					f.puts "      add_index :#{table_name}, [:deep_import_id, :id], :name => 'di_id_index'"
				end
				create_migration( "AddDeepImportBelongsToIndiciesToDeepImport#{model_class.to_s.pluralize}" ) do |f|
					info[:belongs_to].each do |belongs_to|
						f.puts "      add_index :deep_import_#{table_name}, [:deep_import_id, :deep_import_#{belongs_to.to_s.underscore}_id], :name => 'di_#{belongs_to.to_s.underscore}'"
					end
				end
			end
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
			"migration AddDeepImportIdTo#{name.to_s.pluralize} deep_import_id:string"
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

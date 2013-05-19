module DeepImport

	class Setup

		def initialize
			@config = Config.deep_import_config

			enhance_models
			add_deep_import_models

			puts "- " + "git add .".red + "# to add all new generated migration and model files"
			puts "- " "rake db:migrate".red
		end

		def enhance_models 
			@config[:models].each do |model_class,info|
				plural_name = model_class.to_s.pluralize
				table_name = plural_name.underscore
				name = "AddDeepImportIdTo#{plural_name}"

				create_migration( name ) do |f|
					f.puts "    add_column :#{table_name}, :deep_import_id, :string"
					f.puts "    add_index :#{table_name}, [:deep_import_id, :id], :name => 'di_id_index'"
				end
			end
		end

		def add_deep_import_models
			@config[:models].each do |model_class,info|
				generate_deep_import_model_migration( model_class, info )
				generate_deep_import_model_definition( model_class, info )
			end
		end

		def generate_deep_import_model_definition( model_class, info )
			model_file = File.join( Rails.root, "app/models/deep_import_#{model_class.to_s.underscore}.rb" )
			raise "Model File Already Exists: #{model_file}" if File.file? model_file
			File.open( model_file, "w" ) do |f|
				f.puts "class DeepImport#{model_class} < ActiveRecord::Base"
  			f.puts "  attr_accessible :deep_import_id, :parsed_at"
				info[:belongs_to].each do |belongs_to|
					f.puts "  attr_accessible :deep_import_#{belongs_to.to_s.underscore}_id"
				end
				f.puts "end"
			end
			puts "Generated: #{model_file}".green
		end

		def generate_deep_import_model_migration( model_class, info )
			plural_name = model_class.to_s.pluralize
			table_name = plural_name.underscore
			name = "CreateDeepImport#{plural_name}"

			create_migration( name ) do |f|
				f.puts "    create_table :deep_import_#{table_name} do |t|"
				f.puts "      t.string :deep_import_id"
				f.puts "      t.datetime :parsed_at"
				f.puts "      t.timestamps"
				info[:belongs_to].each do |belongs_to|
					f.puts "      t.string :deep_import_#{belongs_to.to_s.underscore}_id"
				end
				f.puts "    end"
				info[:belongs_to].each do |belongs_to|
					f.puts "    add_index :deep_import_#{table_name}, [:deep_import_id, :deep_import_#{belongs_to.to_s.underscore}_id], :name => 'di_#{belongs_to.to_s.underscore}'"
				end
			end
		end

		def create_migration( name )
			raise "Already a migration named: #{name}, suggest: rm db/migrate/*deep_import*" if Dir.glob( "db/migrate/*_#{name.underscore}.rb" ).size > 0
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

	end
end

module DeepImport

	class Setup

		def initialize
			config = DeepImport::Config.new
			raise "Cannot run setup, invalid config file" unless config.valid?
			@models = Config.models

			# populate these
			@migration_name = DeepImport.settings[ :migration_name ]
			@migration_logic = Array.new
			@generated_files = Array.new

			add_source_model_schema_changes
			add_deep_import_model_schema_changes
			add_deep_import_model_definitions

			create_migration

			puts "Generated Files, Add To Revision Control".green
			puts @generated_files.to_yaml
		end

		def add_source_model_schema_changes
			@models.each do |model_class,info|
				table_name = model_class.to_s.underscore.pluralize
				@migration_logic << "add_column :#{table_name}, :deep_import_id, :string"
				@migration_logic << "add_index :#{table_name}, [:deep_import_id, :id], :name => 'di_id_index'"
			end
		end

		def add_deep_import_model_schema_changes
			@models.each do |model_class,info|
				add_deep_import_model_migration( model_class, info )
			end
		end

		def add_deep_import_model_migration( model_class, info )
			plural_name = model_class.to_s.pluralize
			table_name = plural_name.underscore
			@migration_logic <<  "create_table :deep_import_#{table_name} do |t|"
			@migration_logic <<  "  t.string :deep_import_id"
			@migration_logic <<  "  t.datetime :parsed_at"
			@migration_logic <<  "  t.timestamps"
			info[:belongs_to].keys.each do |belongs_to|
				@migration_logic <<  "  t.string :deep_import_#{belongs_to.to_s.underscore}_id"
			end
			@migration_logic <<  "end"
			info[:belongs_to].keys.each do |belongs_to|
				@migration_logic <<  "add_index :deep_import_#{table_name}, [:deep_import_id, :deep_import_#{belongs_to.to_s.underscore}_id], :name => 'di_#{belongs_to.to_s.underscore}'"
			end
		end

		def add_deep_import_model_definitions
			@models.each do |model_class,info|
				generate_deep_import_model_definition( model_class, info )
			end
		end

		def generate_deep_import_model_definition( model_class, info )
			model_file = File.join( Rails.root, "app/models/deep_import_#{model_class.to_s.underscore}.rb" )
			raise "Model File Already Exists: #{model_file}" if File.file? model_file
			File.open( model_file, "w" ) do |f|
				f.puts "class DeepImport#{model_class} < ActiveRecord::Base"
				f.puts "  attr_accessible :deep_import_id, :parsed_at"
				info[:belongs_to].keys.each do |belongs_to|
					f.puts "  attr_accessible :deep_import_#{belongs_to.to_s.underscore}_id"
				end
				f.puts "end"
			end
			@generated_files << model_file
		end


		def create_migration
			raise "Already a migration named: #{@migration_name}, run deep_import:teardown" if Dir.glob( "db/migrate/*_#{@migration_name.underscore}.rb" ).size > 0
			migration_file = "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{@migration_name.underscore}.rb"
			File.open( migration_file, "w" ) do |f|
				f.puts "class #{@migration_name} < ActiveRecord::Migration"
				f.puts "  def change"
				@migration_logic.each do |line|
					f.puts "    #{line}"
				end
				f.puts "  end"
				f.puts "end"
			end
			raise "Unable to create migration file: #{migration_file}" unless File.file? migration_file
			@generated_files << migration_file
		end

	end
end

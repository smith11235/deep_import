module DeepImport
	require 'digest/md5'

	class Setup

		def initialize
			config = DeepImport::Config.new
			raise "Cannot run setup, invalid config file" unless config.valid?
			@models = Config.importable

			# populate these
			@migration_name = DeepImport::MIGRATION_NAME
			@migration_logic = Array.new
			@generated_files = Array.new

			add_source_model_schema_changes
			add_deep_import_model_schema_changes

			create_migration

			puts "Generated Files, Add To Revision Control".green
			puts @generated_files.to_yaml
		end

		def md5( input )
			Digest::MD5.hexdigest( input )
		end

		def add_source_model_schema_changes
			@models.each do |model_class|
				table_name = ":#{model_class.to_s.underscore.pluralize}"
				@migration_logic << "add_column #{table_name}, :deep_import_id, :string, :references => false"

				# hash is for postgres index name uniqueness requirements
				@migration_logic << "add_index #{table_name}, [:deep_import_id, :id], :name => 'di_id_#{md5(table_name)}'"
			end
		end

		def add_deep_import_model_schema_changes
			@models.each do |model_class|
				add_deep_import_model_migration(model_class, Config.belongs_to(model_class))
			end
		end

		def add_deep_import_model_migration( model_class, belongs_to )
			plural_name = model_class.to_s.pluralize
			table_name = ":deep_import_#{plural_name.underscore}"
			@migration_logic <<  "create_table #{table_name} do |t|"
			@migration_logic <<  "  t.string :deep_import_id, :references => false"
			@migration_logic <<  "  t.datetime :parsed_at"
			@migration_logic <<  "  t.timestamps"
			belongs_to.each do |belongs|
				@migration_logic <<  "  t.string :deep_import_#{belongs.to_s.underscore}_id, :references => false"
			end
			@migration_logic <<  "end"
			belongs_to.each do |belongs|
				hash_of_source_target = md5( "#{table_name}_#{belongs}" )
				# hash is for postgres index name uniqueness requirements
				index_name = "di_#{belongs.to_s.underscore}_#{hash_of_source_target}"
				@migration_logic <<  "add_index #{table_name}, [:deep_import_id, :deep_import_#{belongs.to_s.underscore}_id], :name => '#{index_name}'"
			end
		end

		def create_migration
			raise "Already a migration named: #{@migration_name}, run deep_import:teardown" if Dir.glob( "db/migrate/*_#{@migration_name.underscore}.rb" ).size > 0
			migration_file = "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{@migration_name.underscore}.rb"
			File.open( migration_file, "w" ) do |f|
        f.puts "class #{@migration_name} < ActiveRecord::Migration[#{Rails.version[/^\d.\d/]}]"
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

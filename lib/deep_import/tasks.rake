namespace :deep_import do 

	desc "Show Deep Import Messages within the log"
	task :show_log do
		puts "Warning: this is a hack, expects Rails.logger to write to log/#{Rails.env}.log".yellow
		puts `grep -P 'DeepImport' log/#{Rails.env}.log`
	end

	desc "Create/Refresh DeepImport model and database modifications based on config/deep_import.yml"
	task :setup => :teardown do 
		ENV["deep_import_disable_railtie"] = "1"
		DeepImport::Setup.new
	end

	# define migration removal tasks that teardown must run before within rake
	def get_migration_files
		migration_name = DeepImport.settings[ :migration_name ]
		migration_file_name = migration_name.underscore
		Dir.glob( "db/migrate/*_#{migration_file_name}.rb" )
	end

	# create a migration task for the migration file
	migration_files = get_migration_files
	raise "Error: too many migration files found, do something better: #{migration_files.to_yaml}".red if migration_files.size > 1 
	remove_migration_task = if migration_files.size == 0
		:no_removal_necessary
	else
		"remove_#{File.basename(migration_files[0],'.rb')}".to_sym
	end

	# define migration task
	task remove_migration_task => :environment do 
		if remove_migration_task == :no_removal_necessary
			puts "no previous migration files to remove".yellow
		else
			puts "Removing migration: #{migration_files[0]} (complete me)".red.on_green
		end
	end

	desc "Remove DeepImport model and database modifications"
	task :teardown => remove_migration_task do 
		DeepImport::Teardown.new
	end

end

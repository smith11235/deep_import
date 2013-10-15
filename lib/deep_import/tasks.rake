namespace :deep_import do 

	desc "Show Config"
	task :show_config => :environment do
		puts DeepImport::Config.models.to_yaml	
	end

	desc "Show Deep Import Messages within the log"
	task :show_log do
		puts "Warning: this is a hack, expects Rails.logger to write to log/#{Rails.env}.log".yellow
		puts `grep --after-context=5 --before-context=1 --perl-regexp 'Deep\\s?Import' log/#{Rails.env}.log`
	end

	desc "Create/Refresh DeepImport model and database modifications based on config/deep_import.yml"
	task :setup => :teardown do 
		ENV["deep_import_disable_railtie"] = "1"
		DeepImport::Setup.new

		if set_target_migration_version # get the file we just generated
			Rake::Task['db:migrate:up'].reenable
			Rake::Task['db:migrate:up'].invoke
		else
			raise "Error: Migration file not generated".red
		end
	end

	desc "Remove DeepImport model and database modifications"
	task :teardown => :environment do 
		if set_target_migration_version # get the file we want to remove 
			Rake::Task['db:migrate:down'].reenable
			Rake::Task['db:migrate:down'].invoke
		else
			puts "No prior migration file to remove".green
		end

		DeepImport::Teardown.new # removes generated files
	end

	# define migration removal tasks that teardown must run before within rake
	def set_target_migration_version
		migration_name = DeepImport.settings[ :migration_name ]
		migration_file_name = migration_name.underscore
		migration_files = Dir.glob( "db/migrate/*_#{migration_file_name}.rb" )
		raise "Error: too many migration files found, do something better: #{migration_files.to_yaml}".red if migration_files.size > 1 

		if migration_files.size == 1  		
			migration_file = migration_files[0] 
			migration_date = migration_file[/\d{14}/] # get the timestamp of this migration
			puts "Setting Migration VERSION=#{migration_date}".red.on_green
			ENV['VERSION'] = migration_date # set a specific migration to apply in ENV variable
			# ^^^ this is used by db:migrate:[up|down]
			true
		else
			nil
		end
	end



end

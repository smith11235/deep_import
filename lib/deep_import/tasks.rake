namespace :deep_import do 

	desc "Create migrations based on config/deep_import.yml"
	task :setup do 
		ENV["deep_import_disable_railtie"] = "1"
		Rake::Task["deep_import:setup:teardown"].invoke
		Rake::Task["deep_import:setup:setup"].invoke
	end

	namespace :setup do
		task :teardown do 
			generated_files = Dir.glob( "app/models/deep_import_*.rb" ) + Dir.glob( "db/migrate/*_deep_import_*.rb" )
			generated_files.each do |file|
				puts "Removing: #{file}"
				FileUtils.rm( file )
			end
		end

		task :setup_internal => :environment do
			DeepImport::Setup.new
		end
	end

end

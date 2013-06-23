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

	desc "Remove DeepImport model and database modifications"
	task :teardown => :environment do 
		DeepImport::Teardown.new
	end

end

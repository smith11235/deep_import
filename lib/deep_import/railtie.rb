module DeepImport 
	class Railtie < Rails::Railtie
		railtie_name :deep_import
		
		initializer "deep_import.initializer" do
			DeepImport.logger ||= DeepImport.default_logger
      DeepImport.initialize!
		end

		rake_tasks do
			load "deep_import/tasks.rake"
		end

	end
end

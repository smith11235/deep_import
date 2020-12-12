module DeepImport 
	class Railtie < Rails::Railtie
		railtie_name :deep_import
		
=begin
# If anything is needed on rails startup
		initializer "deep_import.initializer" do
		end
=end

		rake_tasks do
			load "deep_import/tasks.rake"
		end

	end
end

require 'deep_import'
require 'rails'

module DeepImport 
	class Railtie < Rails::Railtie
		railtie_name :deep_import

		initializer "deep_import.load_environment_enhancement" do
			Initializer.setup
		end

		rake_tasks do
			load "deep_import/tasks.rake"
		end

	end

end

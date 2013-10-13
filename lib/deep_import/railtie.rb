require 'deep_import'
require 'rails'


module DeepImport 
	class Railtie < Rails::Railtie
			railtie_name :deep_import

			initializer "deep_import/initializer" do
				Initializer.new
			end

			rake_tasks do
				load "deep_import/tasks.rake"
			end

		end
	end

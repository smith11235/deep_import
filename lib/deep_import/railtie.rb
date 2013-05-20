require 'deep_import'
require 'rails'

module DeepImport 
	class Railtie < Rails::Railtie
		railtie_name :deep_import

		initializer "deep_import.load_environment_enhancement" do
			Config.setup # ensure global application settings are initialized

			if ENV["deep_import_disable_railtie"]
				puts "Disabling deep_import rails setup".yellow
			else
				ModelsCache.setup 
				Config.models.each do |model_class,info|
					ModelLogic.new(  model_class  ) # add deep import logic to that model class
				end
			end

		end

		rake_tasks do
			load "deep_import/deep_import.rake"
		end
	end
end

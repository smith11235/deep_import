require 'deep_import'
require 'rails'

module DeepImport 
	class Railtie < Rails::Railtie
		railtie_name :deep_import

		initializer "deep_import.load_environment_enhancement" do
			Config.setup 
			ModelsCache.setup 

			Config.models.each do |model_class,info|
				ModelLogic.new(  model_class  ) # add deep import logic to that model class
			end
		end

		rake_tasks do
			load "lib/tasks/deep_import.rake"
		end
	end
end

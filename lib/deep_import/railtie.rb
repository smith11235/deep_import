require 'deep_import'
require 'rails'

module DeepImport 
	class Railtie < Rails::Railtie
		railtie_name :deep_import

		initializer "deep_import.add_model_creation_after_initialization" do
			Config.setup

			# for each model in configuration file
			Config.models.each do |model_class,info|
				ModelLogic.new(  model_class  )
			end
		end

		rake_tasks do
			load "deep_import/deep_import.rake"
		end
	end
end

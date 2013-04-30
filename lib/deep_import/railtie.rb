require 'deep_import'
require 'rails'

module DeepImport 
	class Railtie < Rails::Railtie
		railtie_name :deep_import

		rake_tasks do
			load "deep_import/deep_import.rake"
		end
	end
end

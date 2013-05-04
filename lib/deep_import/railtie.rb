require 'deep_import'
require 'rails'

module DeepImport 
	class Railtie < Rails::Railtie
		railtie_name :deep_import

		initializer "deep_import.add_model_creation_after_initialization" do
  		%w( DummyModel ).each do |model_name|
				model_class = model_name.classify
				puts model_class
  			Kernel.const_get(model_class).class_eval do 
					after_initialize do |dummy_model|
						puts "Whoa! just initialized a #{model_name}"
					end
				end
  		end
			
		end

		rake_tasks do
			load "deep_import/deep_import.rake"
		end
	end
end

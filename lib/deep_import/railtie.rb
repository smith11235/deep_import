require 'deep_import'
require 'rails'

module DeepImport 
	class Railtie < Rails::Railtie
		railtie_name :deep_import

		initializer "deep_import.add_model_creation_after_initialization" do

			# for each model class in the config
  		%w( DummyModel ).each do |model_name|
				model_class = Kernel.const_get( model_name.classify )

				# add some logic to the model class
  			model_class.class_eval do 
					# http://guides.rubyonrails.org/active_record_validations_callbacks.html#after_initialize-and-after_find
					after_initialize do |dummy_model|
						if dummy_model.name =~ /child/
							puts "- #{dummy_model.name}"
						else
							puts "#{dummy_model.name}".black.on_green 
						end
					end
				end

  		end
			
		end

		rake_tasks do
			load "deep_import/deep_import.rake"
		end
	end
end

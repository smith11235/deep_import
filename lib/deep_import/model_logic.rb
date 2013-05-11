module DeepImport 

	class ModelLogic

		def initialize( model_class )
			@model_class = model_class
			add_class_methods

			# call setup logic
			@model_class.deep_import_setup
		end

		def add_class_methods
			# add some logic to the model class
			@model_class.class_eval do 
				# make the model class aware of it's deep import id
  			attr_accessible :deep_import_id 

				# give the model class a Deep Import models cache from this point on
				@@models_cache ||= DeepImport::ModelsCache.new
			
				# after each model initialization, run this method
				# http://guides.rubyonrails.org/active_record_validations_callbacks.html#after_initialize-and-after_find
				after_initialize :deep_import_after_initialize
				def deep_import_after_initialize
					@@models_cache.add( self )
				end

				# for startup setup
				def self.deep_import_setup
					@@parent = DeepImport::Config.parent_class_of self
				end

			end

		end
	end

end
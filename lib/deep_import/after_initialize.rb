module DeepImport 

	class AfterInitialize

		def initialize( model_name )
			# get the class constant
			@model_class = Kernel.const_get( model_name.classify )
			add_class_methods
		end

		def add_class_methods
			# add some logic to the model class
			@model_class.class_eval do 
				# give the model class a Deep Import models cache
				@@models_cache ||= DeepImport::ModelsCache.new
				# after each model initialization, run this method
				# http://guides.rubyonrails.org/active_record_validations_callbacks.html#after_initialize-and-after_find
				after_initialize :deep_import_after_initialize
				def deep_import_after_initialize
					@@models_cache.add( self )
				end

			end

		end
	end

end

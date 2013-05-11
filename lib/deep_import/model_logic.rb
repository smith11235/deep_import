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
			
				# after each model initialization, run this method
				# http://guides.rubyonrails.org/active_record_validations_callbacks.html#after_initialize-and-after_find
				after_initialize :deep_import_after_initialize
				def deep_import_after_initialize
					DeepImport::ModelsCache.add( self )
				end

				def self.deep_import_setup
					@@parent = DeepImport::Config.parent_class_of self
					puts "Setting parent of #{self} to #{@@parent}"
					DeepImport::ModelsCache.track_model self
				end

				def self.parent_class
					puts "Parent of #{self} is #{@@parent}".yellow
					@@parent
				end

			end

		end
	end

end

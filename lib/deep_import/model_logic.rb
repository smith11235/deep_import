module DeepImport 

	class ModelLogic

		def initialize( model_class )
			@model_class = model_class
			add_class_methods

			# call setup logic
			@model_class.deep_import_setup
		end

		def add_class_methods
			@model_class.class_eval do 
				attr_accessible :deep_import_id # expose the deep import id

				# after each model initialization, run this method
				# http://guides.rubyonrails.org/active_record_validations_callbacks.html#after_initialize-and-after_find
				after_initialize :deep_import_after_initialize

				def deep_import_after_initialize
					# this is called after new and find, we want to check if this really is new
					return unless self.new_record? # if its a preexisting model
					return unless self.deep_import_id.nil? # if it already has a deep import id
					return unless ENV["disable_deep_import"].nil? # if deep_import functionality is disabled

					DeepImport::ModelsCache.add( self )
				end

				def self.deep_import_setup
					DeepImport::ModelsCache.track_model self
				end

				def self.parent_class
					DeepImport::Config.parent_class_of self
				end

			end

		end
	end

end

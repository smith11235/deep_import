module DeepImport 

	def self.add_model_logic_to( model_class )
		# meta-programming reference: http://www.vitarara.org/cms/ruby_metaprogamming_declaratively_adding_methods_to_a_class
		# on tweaking rails: http://errtheblog.com/posts/18-accessor-missing
		# on rails model callbacks: http://guides.rubyonrails.org/active_record_validations_callbacks.html#after_initialize-and-after_find
		model_class.class_eval do
			# pull in the deep import logic
			include DeepImport::ModelLogicEnhancements 
		end

		model_class.setup # run the setup method exposed by ModelLogicEnhancements

		model_class.class_eval do
			# todo: remove this
			def self.parent_class
				DeepImport::Config.parent_class_of self
			end
		end	

	end

	module ModelLogicEnhancements

		def self.included(base) # :nodoc:
			base.extend ClassMethods
		end

		module ClassMethods
			def setup
				send :attr_accessible, :deep_import_id # expose the deep_import_id methods

				setup_after_initialization_callback

			end

			def setup_after_initialization_callback 
				# add the after initialization callback method
				send :define_method, :deep_import_after_initialize do
					# this is called after new and find, we want to check if this really is new
					return unless self.new_record? # if its a preexisting model
					return unless self.deep_import_id.nil? # if it already has a deep import id
					return unless ENV["disable_deep_import"].nil? # if deep_import functionality is disabled
					# add this new instance to the cache
					DeepImport::ModelsCache.add( self )
				end
				# add a callback to 'deep_import_after_initialize' after each model initialization
				send :after_initialize, :deep_import_after_initialize
			end

		end

	end

end

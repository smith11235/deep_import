module DeepImport 
=begin
	meta-programming reference: http://www.vitarara.org/cms/ruby_metaprogamming_declaratively_adding_methods_to_a_class
	on tweaking rails: http://errtheblog.com/posts/18-accessor-missing
	on rails model callbacks: http://guides.rubyonrails.org/active_record_validations_callbacks.html#after_initialize-and-after_find
=end

	def self.add_model_logic_to( model_class )
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

				setup_association_logic
			end

			def setup_association_logic
				DeepImport::Config.models[ self ][:belongs_to].each do |belongs_to_class|
					setup_belongs_to_association( belongs_to_class )
				end
				DeepImport::Config.models[ self ][:has_one].each do |has_one_class|
					setup_has_one_association( has_one_class )
				end
				DeepImport::Config.models[ self ][:has_many].each do |has_many_class|
					setup_has_many_association( has_many_class )
				end
			end

			def setup_has_many_association( has_many_class )
				puts "Setup #{self}.has_many #{has_many_class}".yellow
			end

			def	setup_has_one_association( has_one_class )
				override_active_record_singular_association has_one_class
			end

			def	setup_belongs_to_association( belongs_to_class )
				override_active_record_singular_association belongs_to_class
			end

=begin
- warning: should i reverse the models cache call for the has_one direction
	- so that the ids get set on the correct class

- add in logic for:
						- other=  # done
						- build_other( attributes = {} )
						- create_other( attributes = {} )
						- create_other!( attributes = {} )
=end
			def override_active_record_singular_association( model_class )
				# get the setter name, and the new name for the setter
				model_method = "#{model_class.to_s.underscore}=".to_sym
				inner_model_method = "original_active_record_#{model_method}=".to_sym

				# copy the standard method to the new name so that we can redefine the standard method
				send :alias_method, inner_model_method, model_method 

				# define the new logic with deep import intercept
				send :define_method, model_method do |belongs_to_instance|
					DeepImport::ModelsCache.set_association_on( self, belongs_to_instance )
					send inner_model_method, belongs_to_instance
				end
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

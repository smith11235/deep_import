module DeepImport 

	module ModelsCache
	  @@cache = nil

		def self.reset
	    @@cache = Cache.new
		end

		def self.add( model_instance )
			@@cache.add( model_instance )
		end

		def self.set_association_on( instance, belongs_to_instance )
			@@cache.set_association_on( instance, belongs_to_instance )
		end

		def self.cached_instances( model_class )
			raise "#{model_class} not in cache" unless @@cache.raw_cache.has_key? model_class
			instances = @@cache.raw_cache[ model_class ]
			instances.values
		end

		def self.empty?
      return true if @@cache.nil?
      s = stats
			vals = s.values
      return true if vals.nil?
      vals = vals.uniq
      if vals.size == 1 && vals.first == 0
        true
      else
        false
      end
		end

		def self.stats
			stats = Hash.new
			@@cache.raw_cache.each do |model_class,instances|
				stats[model_class] = instances.size
			end
			stats
		end

		private

		class Cache
			def initialize
				@model_instance_cache = Hash.new
			  DeepImport::Config.importable.each do |model_class| 
				  track_model(model_class)
			  end
			end

			def track_model( model_class )
				# ensure tracking arrays are setup
				@model_instance_cache[ model_class ] = Hash.new
				deep_model_class = "DeepImport#{model_class}".constantize
				@model_instance_cache[ deep_model_class ] = Hash.new
			end

			def raw_cache
				@model_instance_cache
			end

			def set_association_on( instance, belongs_to_instance )
				model_class = instance.class # aka: Child
				deep_import_id = instance.deep_import_id

				deep_import_model_class = "DeepImport#{model_class}".constantize
				deep_instance = @model_instance_cache[ deep_import_model_class ][ deep_import_id ]
				raise "#{deep_import_model_class} missing for deep_import_id=#{deep_import_id}" if deep_instance.nil?

        belongs_to_class = belongs_to_instance.class.to_s # aka: Parent 

        polymorph_as = nil
        alt_names = DeepImport::Config.polymorphic(model_class)
        unless alt_names.empty?
          # TODO: set_association_on needs to be sent explicitly with an 3rd param of "belongs_to_field"
          # - to support a model with multiple polymorphic fields
          # - might need to ditch config file, or replicate other options like
          # - User: belongs_to Manager, class_name: User # non standard table name references
          # - or, ditch the multiple deep import tables (1 per model) in favor of
          # - - DeepImportInstances, DeepImportLinks tables - update queries to run for each belongs_to_type
          belongs_to_class = alt_names.first 
          polymorph_as = belongs_to_class.class.to_s
        end

				deep_import_belongs_to_field_setter = "deep_import_#{belongs_to_class.underscore}_id="
				raise "Error: #{deep_instance} doesnt respond to #{deep_import_belongs_to_field_setter}" unless deep_instance.respond_to? deep_import_belongs_to_field_setter.to_sym

				belongs_to_deep_import_id = belongs_to_instance.deep_import_id
				raise "Invalid belongs_to_deep_import_id for #{belongs_to_instance.to_yaml}" unless belongs_to_deep_import_id =~ /\d+/

				deep_instance.send( deep_import_belongs_to_field_setter, belongs_to_deep_import_id )
        if polymorph_as
          # TODO: as with above alternate schema idea, always save type?
				  deep_import_belongs_to_field_setter = "deep_import_#{belongs_to_class.underscore}_type="
				  deep_instance.send(deep_import_belongs_to_field_setter, polymorph_as) # save Parent class type
        end
			end

			def add( model_instance )
				model_class = model_instance.class

				model_instance.deep_import_id = next_id_for( model_class )

				add_instance_to_cache( model_instance )
			end

			private

			def next_id_for( model_class )
				# if fetch fails its because the class isnt tracked
				instances = @model_instance_cache.fetch model_class 
				instances.size.to_s
			end

			def add_instance_to_cache( model_instance )
				@model_instance_cache[ model_instance.class ][ model_instance.deep_import_id ] = model_instance

				deep_model_class = "DeepImport#{model_instance.class}".constantize
				deep_model_instance = deep_model_class.new( :deep_import_id => model_instance.deep_import_id )
				@model_instance_cache[ deep_model_instance.class ][ deep_model_instance.deep_import_id ] = deep_model_instance
			end
		end

	end

end


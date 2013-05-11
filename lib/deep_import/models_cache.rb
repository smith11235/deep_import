module DeepImport 

	class ModelsCache

		def self.get_cache
			@@cache.raw_cache
		end

		def self.show_stats
			puts "Models:"
			DeepImport::ModelsCache.get_cache.each do |model_class,instances|
				puts "- #{model_class}: #{instances.size}"
			end
		end

		def self.setup
			@@cache = Cache.new
		end

		def self.add( model_instance )
			@@cache.add( model_instance )
		end

		def self.track_model( model_class )
			@@cache.track_model( model_class )
		end

		private

		class Cache
			def initialize
				@@model_instance_cache ||= Hash.new
				@@last_instance_of ||= Hash.new
			end

			def track_model( model_class )
				# ensure tracking arrays are setup
				@@model_instance_cache[ model_class ] ||= Hash.new
				deep_model_class = "DeepImport#{model_class}".constantize
				@@model_instance_cache[ deep_model_class ] ||= Hash.new
			end

			def raw_cache
				@@model_instance_cache
			end

			def add( model_instance )
				# get the two relevant class names
				model_class = model_instance.class
				deep_model_class = "DeepImport#{model_class}".constantize

				# get the next deep import batch id for this class
				deep_import_id = next_id_for( model_class )

				# set the id on the model
				model_instance.deep_import_id = deep_import_id

				# create the deep model instance, with the deep_import_id
				deep_model_instance = deep_model_class.new( :deep_import_id => deep_import_id )

				# check if it has a parent
				parent_class = model_class.parent_class

				if parent_class 
					# only set parent information on DeepImport models
					deep_parent_class = "DeepImport#{parent_class}".constantize
					deep_parent_instance = last_instance_of( deep_parent_class )
					raise "Missing Parent Of Type: #{deep_parent_class}" if deep_parent_instance.nil?
					deep_model_instance.send( "#{deep_parent_class.to_s.underscore}_id=", deep_parent_instance.deep_import_id )
				end

				# cache these classes for creation later
				add_instance_to_cache( model_instance )
				add_instance_to_cache( deep_model_instance )
			end


			private

			def next_id_for( model_class )
				@@model_instance_cache[ model_class ].size.to_s
			end

			def last_instance_of( model_class )
				@@last_instance_of[ model_class ]
			end


			def add_instance_to_cache( model_instance )
				@@model_instance_cache[ model_instance.class ][ model_instance.deep_import_id ] = model_instance
				@@last_instance_of[ model_instance.class ] = model_instance
			end
		end

	end

end


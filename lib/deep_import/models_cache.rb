module DeepImport 

	class ModelsCache

		def self.get_cache
			@@model_instance_cache
		end

		def self.show_stats
			puts "Models:"
			DeepImport::ModelsCache.get_cache.each do |model_class,instances|
				puts "- #{model_class}: #{instances.size}"
			end
		end

		def initialize
			@@model_instance_cache ||= Hash.new
		end

		def add( model_instance )
			# ensure tracking arrays are setup
			@@model_instance_cache[ model_instance.class ] ||= Hash.new
			deep_model_class = "DeepImport#{model_instance.class}".constantize
			@@model_instance_cache[ deep_model_class ] ||= Hash.new

			# get the new deep import id for this class
			deep_import_id = @@model_instance_cache[ model_instance.class ].size.to_s
			# set the id on the model instance
			model_instance.deep_import_id = deep_import_id
			# create the deep model instance
			deep_model_instance = deep_model_class.new( :deep_import_id => deep_import_id )
			
			# cache these classes
			@@model_instance_cache[ model_instance.class ][ deep_import_id ] = model_instance
			@@model_instance_cache[ deep_model_class ][ deep_import_id ] = deep_model_instance

			# 
		end

	end

end


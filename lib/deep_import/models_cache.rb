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
			@@model_instance_cache[ model_instance.class ] ||= Hash.new
			deep_import_id = @@model_instance_cache[ model_instance.class ].size
			@@model_instance_cache[ model_instance.class ][ deep_import_id ] = model_instance
		end

	end

end


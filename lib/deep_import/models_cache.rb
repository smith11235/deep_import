module DeepImport 

	class ModelsCache

		def self.get_cache
			@@model_instance_cache
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


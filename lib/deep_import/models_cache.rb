module DeepImport 

	class ModelsCache

		def self.get_cache
			@@model_instance_cache
		end

		def initialize( model_class )
			@model_class = model_class

			@@model_instance_cache ||= Hash.new
			@@model_instance_cache[ @model_class ] ||= Hash.new
		end

		def add( model_instance )
			deep_import_id = @@model_instance_cache[ @model_class ].size
			@@model_instance_cache[ @model_class ][ deep_import_id ] = model_instance
		end

	end

end


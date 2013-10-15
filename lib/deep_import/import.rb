module DeepImport
	mattr_reader :import_options

	def self.import( options = {}, &import_block )
		if DeepImport.status != :ready_to_import
			raise "Cannot import, status = #{DeepImport.status}, correct or remove config/deep_import.yml"
		end

		DeepImport.validate_import_options options

		# ensure models are setup with deep import logic
		DeepImport::Config.models.keys.each do |model_class| 
			model_class.class_eval { include DeepImport::ModelLogic }
		end

		# renew the background models cache
		DeepImport::ModelsCache.reset

		# enable model tracking behavior
		DeepImport.status = :importing

		# call users logic
		import_block.call

		# commit all models from the cache into the database
		DeepImport.commit

		# flag the system as ready for use again
		DeepImport.status = :ready_to_import
	end

	private

	def self.validate_import_options options
		valid_values = {
			:on_save => [ :raise_error, :noop ]
		}

		defaults = Hash.new
		valid_values.each { |option,values| defaults[ option ] = values.first }
		# validate the options
		options.each do |option,value|
			raise "Unknown Import Option: #{option}" unless valid_values.keys.include? option
			raise "Unknown #{option} => #{value}, expecting #{valid_values[option]}" unless valid_values[ option ].include? value
		end

		# assign the options for reuse
		@@import_options = options.reverse_merge defaults
	end
end

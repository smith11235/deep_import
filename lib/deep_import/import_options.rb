module DeepImport

	mattr_reader :import_options

	private

	def self.import_options=( options )
		import_options = ImportOptions.new( options )
		options = import_options.to_hash

		@@import_options ||= options

		if options != @@import_options
			DeepImport.logger.error "Error: deep import can only be called with one set of import options currently" 
			DeepImport.logger.error "Previous: #{@@import_options.to_yaml}"
			DeepImport.logger.error "Current: #{optionsoptions.to_yaml}"
			raise "Improperly configured import options, see log"
		end
	end

	class ImportOptions
		def initialize( options )
			@options = options
			add_defaults
			DeepImport.logger.info "DeepImport.import_options".green
			DeepImport.logger.info "#{@options.to_yaml}".yellow
			validate
		end

		def to_hash
			return @options
		end

		private

		def valid_key_values
			{
				:on_save => [ :raise_error, :noop ]
			}
		end

		def default_values
			defaults = Hash.new
			valid_key_values.each { |option,values| defaults[ option ] = values.first }
			return defaults
		end

		def add_defaults
			@options.reverse_merge! default_values
		end

		def validate
			valid_values = valid_key_values
			# validate the options
			@options.each do |option,value|
				raise "Unknown Import Option: #{option}" unless valid_values.keys.include? option
				raise "Unknown #{option} => #{value}, expecting #{valid_values[option]}" unless valid_values[ option ].include? value
			end
		end
	end
end

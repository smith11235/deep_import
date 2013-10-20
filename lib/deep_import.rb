module DeepImport

	require 'colorize'
	require 'activerecord-import'

	mattr_accessor :logger # default to Rails.logger in railtie, can be set by user 

	mattr_accessor :status
	@@status = :init

	mattr_accessor :settings 
	@@settings = { 
		:migration_name => "AddDeepImportEnhancements", 
		:required_status_for_import => :ready_to_import, 
		:enable_import_logic_status => :importing  
	}

	def self.mark_ready_for_import!
		DeepImport.status = DeepImport.settings[:required_status_for_import]
	end

	def self.ready_for_import?
		DeepImport.status == DeepImport.settings[:required_status_for_import]
	end

	def self.mark_importing!
		DeepImport.status = DeepImport.settings[:enable_import_logic_status] 
	end

	def self.importing?
		DeepImport.status == DeepImport.settings[:enable_import_logic_status] 
	end

	# root code directory
	root = File.dirname( File.expand_path( __FILE__ ) )
	root = File.join root, "deep_import"

	%w( config setup teardown model_logic models_cache commit railtie import ).each do |file|
		require File.join( root, file )
	end

	def self.import( options = {}, &import_block )
		DeepImport.setup_environment( options )

		import = Import.new

		import.execute import_block

		import.commit
	end

	mattr_reader :import_options

	private

	# these things should only be done 1 time
	def self.setup_environment( options )
		return true if DeepImport.ready_for_import? # already setup
		raise "Calling setup_environemnt when status != :init; #{DeepImport.status}" unless DeepImport.status == :init

		DeepImport.logger = Rails.logger # steal the rails logger by default

		config = DeepImport::Config.new
		if config.valid?
			DeepImport.mark_ready_for_import! 
		else
			DeepImport.status = :error
			return
		end
		# now configure class logic 
		DeepImport.validate_import_options options

		# ensure models are setup with deep import logic
		DeepImport::Config.models.keys.each do |model_class| 
			model_class.class_eval { include DeepImport::ModelLogic }
		end
	end

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

		full_options = options.reverse_merge defaults
		DeepImport.logger.info "DeepImport.import( options) =\n#{full_options.to_yaml}".green

		# assign the options for reuse
		DeepImport.import_options = full_options
	end
	def self.import_options=( import_options )
		@@import_options = import_options
	end

end

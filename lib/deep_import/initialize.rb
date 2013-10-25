module DeepImport

	def self.initialize!( options = {} )
		DeepImport.logger ||= DeepImport.default_logger
		# validate the import options
		DeepImport.import_options = options

		# check if deep import is already setup
		return true if DeepImport.ready_for_import?

		init = Initialize.new

		case false # failure case 
		when init.parse_config
			DeepImport.logger.error "Failed parsing deep import config"
		when init.modify_target_models
			DeepImport.logger.error "Failed modifying target models" 
		end

	end

	private 

	class Initialize

		def initialize

			# otherwise the expectation is the :init status
			raise "Calling setup_environemnt when status != :init; #{DeepImport.status}" unless DeepImport.status == :init

		end

		# these things should only be done 1 time
		def parse_config
			config = DeepImport::Config.new
			if config.valid?
				DeepImport.mark_ready_for_import! 
			else
				DeepImport.status = :error
			end
		end

		def modify_target_models
			# ensure models are setup with deep import logic
			DeepImport::Config.models.keys.each do |model_class| 
				model_class.class_eval { include DeepImport::ModelLogic }
			end
		end

	end

end

module DeepImport

	def self.initialize!
		Initialize.new
	end

	private 

	class Initialize

		def initialize
			# check if deep import is already setup
			return true if DeepImport.ready_for_import?
			# otherwise the expectation is the :init status
			raise "Calling setup_environemnt when status != :init; #{DeepImport.status}" unless DeepImport.status == :init

			case false # failure case 
			when parse_config
				DeepImport.logger.error "Failed parsing deep import config"
			when modify_target_models
				DeepImport.logger.error "Failed modifying target models" 
			end
		end

		private

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

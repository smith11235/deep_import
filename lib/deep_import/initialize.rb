module DeepImport

	def self.initialize!( options = {} )
		# validate the import options
		DeepImport.import_options = options

		# check if deep import is already setup
		return true if DeepImport.ready_for_import?

		Initialize.new

	end

	private 

	class Initialize

		def initialize
			# otherwise the expectation is the :init status
			raise "Calling setup_environemnt when status != :init; #{DeepImport.status}" unless DeepImport.status == :init
			case false # failure case 
			when parse_config
				DeepImport.logger.error "Failed parsing deep import config"
			when modify_target_models
				DeepImport.logger.error "Failed modifying target models" 
			end
			check_activerecord_import_gem
		end

		def check_activerecord_import_gem
			DeepImport::Config.models.keys.each do |model_class|
				if ! model_class.respond_to? :import
					DeepImport.logger.error "#{model_class} does not respond_to? :import"
					DeepImport.logger.error "this method should exist from deep imports gem dependency on 'activerecord-import'"
					DeepImport.logger.error "Try adding: gem 'activerecord-import', :git => 'git://github.com/zdennis/activerecord-import.git' to your Gemfile"

					raise "activerecord-import not configured correctly, see deep import log"
				end
			end
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

module DeepImport

	module Initializer
		def self.setup
			# complete removal of deep_import background logic logic
			if DeepImport.railtie_disabled?
				return
			end

			DeepImport.logger = Rails.logger # steal the rails logger by default
			# ^^^ uses the users logging settings by default
			# or the user can define their own

			init = Initializer.new # run the core deep import logic
			init.add_deep_import_logic_to_environment
		end

		private

		class Initializer
			def add_deep_import_logic_to_environment
				Config.setup # ensure global application settings are initialized

				return unless validate_required_models

				ModelsCache.setup # create model tracking structures

				Config.models.each do |model_class,info|
					# add it to the deep import models cache
					DeepImport::ModelsCache.track_model( model_class )
					# enhance the model definition
					DeepImport.add_model_logic_to(  model_class  ) # add deep import logic to that model class
				end
			end

			def validate_required_models
				# check if the environment is complete
				exists = Config.models.collect do |model_class,info|
					[ model_class.to_s, "DeepImport#{model_class}" ].collect do |class_name|
						
						next unless class_name.safe_constantize.nil? # adds true to the exists array
						# but if hte class doesnt exist we have a problem

						DeepImport.logger.error "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv".black.on_red
						DeepImport.logger.error "(#{DateTime.now}) Deep Import Railtie Error".black.on_red
						DeepImport.logger.error "#{model_class} is not available:".black.on_red
						if model_class =~ /^DeepImport/
							DeepImport.logger.error "- #{model_class} is supposed to have been a generated model".black.on_red 
						else
							DeepImport.logger.error "- #{model_class} is specified in config/deep_import.yml".black.on_red 
						end
						DeepImport.logger.error "- run $ rake 'deep_import:setup' to correct this, or edit your settings".black.on_red
						DeepImport.logger.error "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^".black.on_red
						false
					end
				end
				# skip deep_import setup if environment is incomplete (missing models)
				return ! exists.flatten.include?( false )
			end

		end
	end

end

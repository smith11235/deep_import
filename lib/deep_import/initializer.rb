module DeepImport

	module Initializer
		def self.setup
			if ENV["deep_import_disable_railtie"]
				puts "DeepImport: ENV[deep_import_disable_railtie] is set, leaving deep_import inactive".yellow
				return
			end
			init = Initializer.new
			init.add_deep_import_to_environment
		end

		private

		class Initializer
			def add_deep_import_to_environment
				DeepImport.logger = Rails.logger # steal the rails logger by default
				# ^^^ a user can also redefine this if they wish

				Config.setup # ensure global application settings are initialized

				ModelsCache.setup # create model tracking structures

				Config.models.each do |model_class,info|
					ModelLogic.new(  model_class  ) # add deep import logic to that model class
				end
			end
		end
	end

end

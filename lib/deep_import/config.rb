module DeepImport

	module Config
		require File.expand_path( '../config_parser', __FILE__  )

		# intended to be called by Railtie
		def self.setup 
			config_parser = ConfigParser.new

			status, @@models = config_parser.parse
			return status
		end

		def self.models
			@@models
		end

	end

end

module DeepImport

	class Initializer

		def initialize
			DeepImport.logger = Rails.logger # steal the rails logger by default
			# ^^^ uses the users logging settings by default
			# or the user can define their own

			status = Config.setup # ensure global application settings are initialized

			DeepImport.status = status

			puts "DeepImport status=#{DeepImport.status}"
		end
	end
end

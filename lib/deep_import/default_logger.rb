module DeepImport
	def self.default_logger_path
		"log/deep_import_#{Rails.env}.log"
	end
	def self.default_logger
		ActiveSupport::TaggedLogging.new(Logger.new( default_logger_path ))
	end
end

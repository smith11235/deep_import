module DeepImport
	def self.default_logger_path
    # TODO: env var override
		"log/deep_import_#{Rails.env}.log"
	end
	def self.default_logger
    # TODO: make param/config option
    output = STDOUT # default_logger_path
		ActiveSupport::TaggedLogging.new(Logger.new(output))
	end
end

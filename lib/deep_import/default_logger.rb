module DeepImport
	def self.default_logger_path
    # TODO: env var override
		"log/deep_import_#{ENV["RAILS_ENV"]}.log"
	end

	def self.default_logger
    # TODO: make param/config option
    output = ENV["DEEP_IMPORT_LOG_FILE"] || STDOUT # default_logger_path
		ActiveSupport::TaggedLogging.new(Logger.new(output))
	end
end

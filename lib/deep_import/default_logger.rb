module DeepImport
	def self.default_logger
		ActiveSupport::TaggedLogging.new(Logger.new( "log/deep_import_#{Rails.env}.log" ))
	end
end

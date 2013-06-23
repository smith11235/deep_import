module DeepImport

	class Teardown
  	
		def initialize
			@config = Config.deep_import_config
			remove_generated_files
		end

		def remove_generated_files
			generated_files = Dir.glob( "app/models/deep_import_*.rb" ) + Dir.glob( "db/migrate/*_deep_import_*.rb" )
			generated_files.each do |file|
				puts "Removing: #{file}"
				FileUtils.rm( file )
			end
		end

	end
end


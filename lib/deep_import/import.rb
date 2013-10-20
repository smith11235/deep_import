module DeepImport
	class Import
		def initialize
 			if ! DeepImport.ready_for_import?
				DeepImport.log.error "Error: While invoking DeepImport.import, DeepImport.status = #{DeepImport.status}".red
				raise "Cannot DeepImport.import, check the log".red
			end

			DeepImport::ModelsCache.reset # renew the background models cache
		end

		def execute( import_block )
			DeepImport.mark_importing!
			import_block.call # call users logic
			DeepImport.mark_ready_for_import!
		end

		def commit
			DeepImport.commit # commit all models from the cache into the database
		end

		private

	end
end

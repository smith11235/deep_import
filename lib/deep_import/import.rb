module DeepImport

	def self.import( options = {}, &import_block )
		DeepImport.logger ||= DeepImport.default_logger
		# validate the import options
		DeepImport.import_options = options
		# initialize the deep import environment modifications
		DeepImport.initialize!

		# now run the import
		import = Import.new
		import.import import_block

		DeepImport.commit! # commit all models from the cache into the database
	end

	private

	class Import
		def initialize
			if ! DeepImport.ready_for_import?
				DeepImport.log.error "Error: While invoking DeepImport.import, DeepImport.status = #{DeepImport.status}".red
				raise "Cannot DeepImport.import, check the log".red
			end

			DeepImport::ModelsCache.reset # renew the background models cache
		end

		def import( import_block )
			# DeepImport.status is used to enable/disable activerecord enhancements
			DeepImport.mark_importing!
			import_block.call # call users logic
			DeepImport.mark_ready_for_import!
		end

	end

end

module DeepImport

	def self.import( options = {}, &import_block )
		start_time = Time.now
		DeepImport.logger.info "Starting Import At #{start_time}"
		DeepImport.logger.info "#{'DeepImport.import:'.green}             #{'(in seconds)     user     system      total        real'.black.on_yellow}"
		# initialize the deep import environment modifications
		DeepImport.logger.info "                                     TIME: #{Benchmark.measure { import_block.call }}"
		DeepImport.logger.info "#{'DeepImport.initialize!:'.green}         TIME: #{Benchmark.measure { import_block.call }}"
		DeepImport.initialize! options

		# now run the import
		import = Import.new
		import.enable_logic import_block

		DeepImport.commit! # commit all models from the cache into the database

		puts "DeepImport.import successful.  Check the log for what happened (default: #{DeepImport.default_logger_path})".green

		end_time = Time.now
		DeepImport.logger.info "Import Ended At #{end_time}, with a duration of #{end_time - start_time} seconds"
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

		def enable_logic( import_block )
			# DeepImport.status is used to enable/disable activerecord enhancements
			DeepImport.mark_importing!

			# call the users block
			DeepImport.logger.info "#{'DeepImport.import:'.green} executing users block"
			DeepImport.logger.info "                                     TIME: #{Benchmark.measure { import_block.call }}"

			DeepImport.mark_ready_for_import!
		end

	end

end

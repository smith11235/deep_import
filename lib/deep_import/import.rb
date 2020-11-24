module DeepImport

	def self.import( options = {}, &import_block )
		start_time = Time.now
		DeepImport.logger.info "" 
		DeepImport.logger.info "" 
		DeepImport.logger.info "==========================================================="
		DeepImport.logger.info "Starting Import At #{start_time}"
		DeepImport.logger.info "==========================================================="
		DeepImport.logger.info "Running with adapter #{ActiveRecord::Base.connection_config[:adapter]}"
    reset = options.has_key?(:reset) ? options.delete(:reset) : Rails.env.test?
    if reset
      DeepImport.status = :init
      DeepImport.import_options = nil
    end
    DeepImport.import_options = options

    # check if deep import is setup on modules

		DeepImport.logger.info "#{'DeepImport.import:'.green}             #{'(in seconds)     user     system      total        real'.black.on_yellow}"
		# initialize the deep import environment modifications

    begin
			# DeepImport.status is used to enable/disable activerecord enhancements
		  DeepImport.logger.info "#{'DeepImport.initialize!:'.green}              TIME: #{Benchmark.measure { DeepImport.initialize! options }}"
      # TODO: take in options here - work as overrides
			if !DeepImport.ready_for_import?
				DeepImport.logger.error "Error: While invoking DeepImport.import, DeepImport.status = #{DeepImport.status}".red
				raise "Cannot DeepImport.import, check the log".red
			end

      puts "Done Initializing".red
			DeepImport.mark_importing!
      puts "Importing!".red
  		import = Import.new # TODO: do we need this?
  		import.enable_logic import_block # run the import/build logic
  		DeepImport.commit! # commit all models from the cache into the database
			DeepImport.mark_ready_for_import!
    rescue Exception => e
      DeepImport.status = :error
      raise e
    end

		puts "DeepImport.import successful.  Check the log for what happened (default: #{DeepImport.default_logger_path})".green

		end_time = Time.now
		DeepImport.logger.info "==========================================================="
		DeepImport.logger.info "Import Ended At #{end_time}, with a duration of #{end_time - start_time} seconds"
		DeepImport.logger.info "==========================================================="
	end

	private

	class Import
		def initialize
			DeepImport::ModelsCache.reset # renew the background models cache
		end

		def enable_logic( import_block )
			# call the users block
			DeepImport.logger.info "#{'DeepImport.import:'.green} building data"
        # TODO: better formating all around
			  DeepImport.logger.info "                                     TIME: #{Benchmark.measure { import_block.call }}"

		end

	end

end

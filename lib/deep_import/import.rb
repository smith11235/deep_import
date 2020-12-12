module DeepImport

	def self.import(options = {}, &import_block)
		start_time = Time.now

    DeepImport.import_options = options

    # Header Row
		DeepImport.logger.info "#{'DeepImport.import:'.green}                       #{'(in seconds)     user     system      total        real'.black.on_yellow}"

    begin
			if !DeepImport.ready_for_import?
				DeepImport.logger.fatal "Error: DeepImport.import - status not ready for import: status=#{DeepImport.status}".red
				raise "Cannot DeepImport.import"
			end

			DeepImport.mark_importing!

	    DeepImport::ModelsCache.reset # renew the background models cache

      DeepImport.log_time("import_block", &import_block)

  		DeepImport.commit! # commit all models from the cache into the database
			DeepImport.mark_ready_for_import!
    rescue Exception => e
      DeepImport.status = :error
      raise e
    end

		end_time = Time.now
		DeepImport.logger.info "Import Ended At #{end_time}: Total Duration: #{end_time - start_time} seconds"
		DeepImport.logger.info "==========================================================="
	end





end

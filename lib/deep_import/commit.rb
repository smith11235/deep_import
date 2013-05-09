module DeepImport

	def self.commit
		puts "Commiting".red
		Commit.new
	end

	class Commit
		def initialize
			DeepImport::ModelsCache.show_stats
			@cache = DeepImport::ModelsCache.get_cache

			puts "ActiveRecord::import:"
			@cache.each do |model_class,instances|
				puts "  -	Importing: #{model_class} - #{instances.size} instances @ #{Time.now}".yellow	
				raise "#{model_class} does not respond to import" unless model_class.respond_to? :import, true
				model_class.import instances.values
				puts "  	Finished".green	
			end

			puts "Setting association ids on application models"
			# for each models belongs_to associations
			# - application => deep_import: <model>.deep_import_id = deep_import_<model>.deep_import_id 
			# - find belongs_to: deep_import_<model>.deep_import_<belongs_to>_id = <belongs_to>.deep_import_id
			# - to set: <model>.<belongs_to>_id = <belongs_to>.id
			
		end

	end

end

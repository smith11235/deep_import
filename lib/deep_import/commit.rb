module DeepImport

	def self.commit
		Commit.new
	end

	private

	class Commit
		def initialize
			DeepImport::ModelsCache.show_stats
			cache = DeepImport::ModelsCache.get_cache

			puts "ActiveRecord::import:"
			cache.each do |model_class,instances|
				puts "  - Importing: #{model_class} - #{instances.size} instances @ #{Time.now}".yellow	
				raise "#{model_class} does not respond to import" unless model_class.respond_to? :import, true
				model_class.import instances.values
				puts "    - todo: check for failures".red
				puts "  	Finished".green	
			end

			puts "Setting associations:"
			Config.deep_import_config[:models].each do |model_class,info|
				info[ :belongs_to ].each do |parent_class|
					target_table = model_class.to_s.underscore.pluralize
					target_association_id_field = parent_class.to_s.underscore + "_id"
					deep_import_target_association_id_field = "deep_import_" + parent_class.to_s.underscore + "_id"
					association_table = parent_class.to_s.underscore.pluralize
					deep_import_target_table = "deep_import_#{target_table}"

					puts "  - set: #{target_table}.#{target_association_id_field} = #{association_table}.id".yellow
					puts "  - join: #{target_table}.deep_import_id = #{deep_import_target_table}.deep_import_id"
					puts "  - join: #{association_table}.deep_import_id = #{deep_import_target_table}.#{deep_import_target_association_id_field}"

					# - application => deep_import: <model>.deep_import_id = deep_import_<model>.deep_import_id 
					# - find belongs_to: deep_import_<model>.deep_import_<belongs_to>_id = <belongs_to>.deep_import_id
					# - to set: <model>.<belongs_to>_id = <belongs_to>.id

					# - get count of records with each distinct deep_import belongs_to id field values
					# - ensure uniqueness is the same on actual association fields
					puts "  Finished".green
				end
			end
			
		end

	end

end

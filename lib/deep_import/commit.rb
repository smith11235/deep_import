module DeepImport

	def self.commit
		Commit.new
	end

	private

	class Commit
		def initialize
			DeepImport::ModelsCache.show_stats
			import_models
			set_associations	
		end

		def set_associations
			puts "Setting associations:"
			Config.deep_import_config[:models].each do |model_class,info|
				info[ :belongs_to ].each do |parent_class|
					# - get count of records with each distinct deep_import belongs_to id field values
					puts mysql_association_update_query(model_class,parent_class).green
					# - ensure uniqueness is the same on actual association fields
					# clear deep_import_id's everywhere
					# delete deep_import models
					puts "  Finished".green
				end
			end
		end

		def mysql_association_update_query(model_class,parent_class)
			target_table = model_class.to_s.underscore.pluralize
			target_association_id_field = parent_class.to_s.underscore + "_id"
			deep_import_target_association_id_field = "deep_import_" + parent_class.to_s.underscore + "_id"
			association_table = parent_class.to_s.underscore.pluralize
			deep_import_target_table = "deep_import_#{target_table}"

			mysql_update_logic = "UPDATE #{target_table}"
			mysql_update_logic << "	JOIN #{deep_import_target_table} ON #{target_table}.deep_import_id = #{deep_import_target_table}.deep_import_id"
			mysql_update_logic << " JOIN #{association_table} ON #{deep_import_target_table}.#{deep_import_target_association_id_field} = #{association_table}.deep_import_id"
			mysql_update_logic << " SET #{target_table}.#{target_association_id_field} = #{association_table}.id"
			mysql_update_logic << " WHERE #{target_table}.deep_import_id IS NOT NULL"
			mysql_update_logic
		end

		def import_models
			cache = DeepImport::ModelsCache.get_cache

			puts "ActiveRecord::import:"
			cache.each do |model_class,instances|
				puts "  - Importing: #{model_class} - #{instances.size} instances @ #{Time.now}".yellow	
				raise "#{model_class} does not respond to import" unless model_class.respond_to? :import, true
				model_class.import instances.values
				puts "    - todo: check for failures".red
				puts "  	Finished".green	
			end
		end

	end

end

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
					# class_name.connection.update_sql()				
					case model_class.connection_config[:adapter]
					when "sqlite3"
						puts sqlite_association_update_query( model_class,parent_class).green
					when /^mysql/
						puts mysql_association_update_query(model_class,parent_class).green
						raise "mysql Not implemented"
					else
						raise "Not implemented"
					end

					# - ensure uniqueness is the same on actual association fields
					# clear deep_import_id's everywhere
					# delete deep_import models
					puts "  Finished".green
				end
			end
		end

		def model_names( model_class, parent_class )
			{
			:target_table => model_class.to_s.underscore.pluralize,
			:target_association_id_field => parent_class.to_s.underscore + "_id",
			:deep_import_target_association_id_field => "deep_import_" + parent_class.to_s.underscore + "_id",
			:association_table => parent_class.to_s.underscore.pluralize,
			:deep_import_target_table => "deep_import_#{model_class.to_s.underscore.pluralize}"
			}
		end

		def sqlite_association_update_query(model_class,parent_class)
			names = model_names( model_class, parent_class )
 			query = "UPDATE #{names[:target_table]}" 
			query << " SET #{names[:target_association_id_field]} = ("
			query << "   	SELECT #{names[:association_table]}.id"
			query << " 		FROM #{names[:association_table]} JOIN #{names[:deep_import_target_table]}"
			query << " 		ON #{names[:association_table]}.deep_import_id = #{names[:deep_import_target_table]}.#{names[:deep_import_target_association_id_field]}"
			query << "    AND #{names[:target_table]}.deep_import_id = #{names[:deep_import_target_table]}.deep_import_id"
			query << "  )"
			query << " WHERE #{names[:target_table]}.deep_import_id IS NOT NULL"
			query
		end

		def mysql_association_update_query(model_class,parent_class)
			names = model_names( model_class, parent_class )
			mysql_update_logic = "UPDATE #{names[:target_table]}"
			mysql_update_logic << "	JOIN #{names[:deep_import_target_table]} ON #{names[:target_table]}.deep_import_id = #{names[:deep_import_target_table]}.deep_import_id"
			mysql_update_logic << " JOIN #{names[:association_table]} ON #{names[:deep_import_target_table]}.#{names[:deep_import_target_association_id_field]} = #{names[:association_table]}.deep_import_id"
			mysql_update_logic << " SET #{names[:target_table]}.#{names[:target_association_id_field]} = #{names[:association_table]}.id"
			mysql_update_logic << " WHERE #{names[:target_table]}.deep_import_id IS NOT NULL"
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

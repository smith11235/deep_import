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
				puts "  - #{model_class}:"
				info[ :belongs_to ].each do |parent_class|
					puts "    - belongs_to: #{parent_class}...".yellow
					names = model_names( model_class, parent_class )

					model_class.joins( "JOIN #{names[:deep_import_target_table]} ON #{names[:target_table]}.deep_import_id = #{names[:deep_import_target_table]}.deep_import_id JOIN #{names[:association_table]} ON #{names[:deep_import_target_table]}.#{names[:deep_import_target_association_id_field]} = #{names[:association_table]}.deep_import_id" ).update_all( "#{names[:target_table]}.#{names[:target_association_id_field]} = #{names[:association_table]}.id", "NOT ISNULL(#{names[:target_table]}.deep_import_id)" )

					# - ensure uniqueness is the same on actual association fields
					# clear deep_import_id's everywhere
					# delete deep_import models
					puts "      - Finished".green
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

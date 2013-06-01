module DeepImport

	def self.commit

		Commit.new
	end

	private

	class Commit
		def initialize
			puts " -- DeepImport.commit cache stats --"
			DeepImport::ModelsCache.show_stats

			puts "                     (in seconds)     user     system      total        real"
			puts "DeepImport.commit:    Importing - #{Benchmark.measure { import_models }}"
			puts "DeepImport.commit: Associations - #{Benchmark.measure { set_associations }}"
			puts "DeepImport.commit:     Deleting - #{Benchmark.measure { delete_deep_import_models }}"
			puts "DeepImport.commit:       Nilify - #{Benchmark.measure { nilify_deep_import_ids }}"
			DeepImport::ModelsCache.clear
		end

		def nilify_deep_import_ids
			Config.deep_import_config[:models].each do |model_class,info|
				model_class.update_all( "deep_import_id = NULL", "NOT ISNULL(deep_import_id)" )
			end
		end
		
		def delete_deep_import_models
			Config.deep_import_config[:models].each do |model_class,info|
				deep_import_model_class = "DeepImport#{model_class}".constantize
				deep_import_model_class.delete_all
			end
		end

		def set_associations
			Config.deep_import_config[:models].each do |model_class,info|
				info[ :belongs_to ].each do |parent_class|
					names = model_names( model_class, parent_class )

					model_class.joins( "JOIN #{names[:deep_import_target_table]} ON #{names[:target_table]}.deep_import_id = #{names[:deep_import_target_table]}.deep_import_id JOIN #{names[:association_table]} ON #{names[:deep_import_target_table]}.#{names[:deep_import_target_association_id_field]} = #{names[:association_table]}.deep_import_id" ).update_all( "#{names[:target_table]}.#{names[:target_association_id_field]} = #{names[:association_table]}.id", "NOT ISNULL(#{names[:target_table]}.deep_import_id)" )

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

			cache.each do |model_class,instances|
				raise "#{model_class} does not respond to import" unless model_class.respond_to? :import, true
				model_class.import instances.values
			end
		end

	end

end

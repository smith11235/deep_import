module DeepImport

	def self.commit
		Commit.new
	end

	private

	class Commit
		def initialize
			DeepImport.logger.info "[DeepImport::ModelsCachse.stats at commit time] #{DeepImport::ModelsCache.stats.to_yaml}"
			DeepImport.logger.info "#{'DeepImport.commit:'.green}             (in seconds)     user     system      total        real"
			DeepImport.logger.info "#{'DeepImport.commit:'.green} STEP=#{'Importing'.red}    TIME: #{Benchmark.measure { import_models }}"
			DeepImport.logger.info "#{'DeepImport.commit:'.green} STEP=#{'Associations'.red} TIME: #{Benchmark.measure { set_associations }}"
			DeepImport.logger.info "#{'DeepImport.commit:'.green} STEP=#{'Validating'.red}   TIME: #{Benchmark.measure { validate_associations }}"
			DeepImport.logger.info "#{'DeepImport.commit:'.green} STEP=#{'Deleting'.red}     TIME: #{Benchmark.measure { delete_deep_import_models }}"
			DeepImport.logger.info "#{'DeepImport.commit:'.green} STEP=#{'Nilify'.red}       TIME: #{Benchmark.measure { nilify_deep_import_ids }}"
			DeepImport::ModelsCache.clear
		end

		def validate_associations
			Config.deep_import_config[:models].each do |model_class,info|
				info[ :belongs_to ].each do |belongs_to_class|
					deep_distribution = get_deep_import_id_distribution model_class, belongs_to_class

					source_distribution = get_source_id_distribution model_class, belongs_to_class

					error_prefix = "Alignment error for belongs to relationship of: #{model_class} belonging to: #{belongs_to_class} - "

					# verify distribution alignment by entry count
					raise "#{error_prefix} deep and source distributions have uneven entries: #{deep_distribution.size} != #{source_distribution.size}" if deep_distribution.size != source_distribution.size

					# verify entry distribution
					source_distribution.each do |deep_import_id,count|
						raise "#{error_prefix} deep distribution for #{deep_import_id} not found but exists in the source tables with #{count} entries" unless deep_distribution.has_key? deep_import_id
						raise "#{error_prefix} deep distribution shows a different number of entries than the source tables: #{deep_distribution[deep_import_id]} vs. #{count}" if count != deep_distribution[deep_import_id]
					end

				end
			end
		end

		def get_source_id_distribution( model_class, belongs_to_class )
			# source model linkings
			model_table = model_class.to_s.pluralize.underscore
			belongs_to_table = belongs_to_class.to_s.pluralize.underscore

			source_distribution = Hash.new
			model_class.joins( belongs_to_class.to_s.underscore.to_sym ).where( "NOT ISNULL(#{model_table}.deep_import_id)" ).group( "#{belongs_to_table}.deep_import_id" ).select( "#{belongs_to_table}.deep_import_id, count( #{model_table}.id ) AS counts" ).each do |record|
				source_distribution[ record.deep_import_id ] = record.counts
			end
			source_distribution
		end

		def get_deep_import_id_distribution( model_class, belongs_to_class )
			belongs_to_id_field = "deep_import_#{belongs_to_class.to_s.underscore}_id"
			deep_model_class = "DeepImport#{model_class}".constantize

			deep_distribution = Hash.new # convert the sql groupy by/count result to a hash
			deep_model_class.group( belongs_to_id_field ).select( "#{belongs_to_id_field} AS deep_import_id, count( id ) AS counts" ).each {|record| deep_distribution[ record.deep_import_id ] = record.counts }	

			deep_distribution
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
				results = model_class.import instances.values
				# todo: num_inserts might be useful to output to log
				if results.failed_instances.size > 0
					raise "Error Inserting #{model_class}, #{results.failed_instances.size}/#{instances.size} failures. Failed Instances: #{results.failed_instances.to_yaml}"
				end
			end
		end

	end

end

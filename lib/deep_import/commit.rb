module DeepImport

	private

	def self.commit!
		# all model saving logic should be within one transaction
		# to help with database locking between multiple processes
		# and to provide roll back support on error

    # Check if nothing to commit
	  noop = DeepImport::Config.importable.all? do |base_class|
		  DeepImport::ModelsCache.cached_instances(base_class).empty?
    end
    if noop
		  DeepImport.logger.warn "- DeepImport.commit! no instances loaded to import"
      return
    end

		ActiveRecord::Base.transaction do
			Commit.new
		end
	end


	class Commit
		def initialize
      @imported = {} # track which model types were loaded, skip empty ones
      DeepImport.log_time("commit.import_models") { import_models }
      DeepImport.log_time("commit.set_associations") { set_associations }
      # DeepImport.log_time("commit.validate") { validate_associations } # TODO: is this necessary? if so, optional
      DeepImport.log_time("commit.deleting_index") { delete_deep_import_models }
      DeepImport.log_time("commit.nilify_ids") { nilify_deep_import_ids }
		end

		def validate_associations
      Config.importable.each do |model_class|
        next unless @imported[model_class]

			  belongs = Config.belongs_to(model_class)
				belongs.each do |belongs_to_class|
          polymorphic = polymorphic?(model_class, belongs_to_class)
          if polymorphic
            puts "UNIMPLEMENTED POLYMORPHIC VALIDATION: #{model_class} => #{belongs_to_class}".red
            next
          end

					deep_distribution = get_deep_import_id_distribution model_class, belongs_to_class

					source_distribution = get_source_id_distribution model_class, belongs_to_class

					error_prefix = "Alignment error: #{model_class} belongs_to: #{belongs_to_class} - "

					# verify distribution alignment by entry count
					if deep_distribution.size != source_distribution.size
						DeepImport.logger.info "source: #{source_distribution.to_yaml}"
						DeepImport.logger.info "deep: #{deep_distribution.to_yaml}"
						raise "#{error_prefix} base and deep_import_* models differ: #{source_distribution.size} != #{deep_distribution.size}" 
					end

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
			belongs_to_association = belongs_to_class.to_s.underscore.to_sym
			model_table = model_class.to_s.pluralize.underscore
			belongs_to_table = belongs_to_class.to_s.pluralize.underscore

			where_clause = field_not_null( "#{model_table}.deep_import_id" )
			group_clause = "#{belongs_to_table}.deep_import_id"
			select_clause = "#{belongs_to_table}.deep_import_id, count( #{model_table}.id ) AS counts"

			source_distribution = Hash.new
			model_class.joins( belongs_to_association ).where( where_clause ).group( group_clause ).select( select_clause ).each do |record|
				source_distribution[ record.deep_import_id ] = record.counts
			end
			source_distribution
		end

		def get_deep_import_id_distribution( model_class, belongs_to_class )
			# what is the deep_import model_class
			deep_model_class = "DeepImport#{model_class}".constantize
			# what is the field name representing belongs_to_class
			belongs_to_id_field = "deep_import_#{belongs_to_class.to_s.underscore}_id"

			# for each belongs_to_class id, how many model_class's have it
			select_clause = "#{belongs_to_id_field} AS deep_import_id, count( id ) AS counts"
			# only for records that have a tracked relationship
			where_clause = field_not_null( belongs_to_id_field )

			deep_distribution = Hash.new # convert the sql groupy by/count result to a hash
			deep_model_class.where( where_clause ).group( belongs_to_id_field ).select( select_clause ).each do |record| 
				deep_distribution[ record.deep_import_id ] = record.counts 
			end

			deep_distribution
		end

		def field_not_null( field )
			case adapter
			when "postgresql"
				"#{field} NOTNULL"
			when "mysql2"
				"#{field} IS NOT NULL"
			end
		end

		def nilify_deep_import_ids
			Config.importable.each do |model_class|
				model_class.where.not(deep_import_id: nil).update_all(deep_import_id: nil)
			end
		end

		def delete_deep_import_models
			Config.importable.each do |model_class|
				deep_import_model_class = "DeepImport#{model_class}".constantize
				deep_import_model_class.delete_all
			end
		end

    def polymorphic?(child_class, parent_class)
      Config.polymorphic(child_class).include?(parent_class)
    end


		def set_associations
      # TODO: use joins/active record code here
      Config.importable.each do |model_class|
        next unless @imported[model_class]

			  belongs = Config.belongs_to(model_class)
				belongs.each do |parent_class|
          # setting {model_class}_table.{parent_class}_id
          # joining through deep import index, to associated table
          polymorphic = polymorphic?(model_class, parent_class)

          if polymorphic # alternate routine
            type_field = "#{parent_class.underscore.singularize}_type"
            filled = {
              :deep_import_id => nil,
              type_field => nil
            }
            empty = { "#{parent_class.underscore.singularize}_id": nil }
            types = model_class.where.not(filled).where(empty).select("DISTINCT(#{type_field})").collect{|i| i.send(type_field)}
            types.each do |parent_type|
              sql = polymorphic_belongs_to_association_sql(model_class, parent_class, parent_type)
              execute(sql)
            end
          else
            sql = belongs_to_association_sql(model_class, parent_class)
            execute(sql)
          end
				end
			end
		end

    def polymorphic_belongs_to_association_sql(child_class, ref_name, parent_type)
      # InLaw, relation, Parent
      case adapter
      when "postgresql"
        polymorphic_belongs_to_sql(child_class, ref_name, parent_type)
      when "mysql2"
        raise "TODO: mysql2 set polymorphic association query"
      end
    end

    def polymorphic_belongs_to_sql(child_class, ref_name, parent_type)
      child_table = child_class.to_s.tableize
      "
				UPDATE 
					#{child_table} AS child_table
				SET
					#{ref_name}_id = parent_table.id
				FROM
					deep_import_#{child_table} AS index_table,
					#{parent_type.tableize} AS parent_table 
				WHERE
          child_table.#{ref_name}_type = '#{parent_type}'
        AND
					child_table.deep_import_id = index_table.deep_import_id 
				AND
					index_table.deep_import_#{ref_name}_id = parent_table.deep_import_id
				AND
					child_table.deep_import_id NOTNULL
      "
    end

    def belongs_to_association_sql(child_class, parent_class)
      # TODO: change model_names to be child/parent/index consistently
			names = model_names(child_class, parent_class)
      case adapter
      when "postgresql"
      	postgresql_association_logic names
      when "mysql2"
      	mysql2_association_logic names
      end
=begin
# TODO: why doesnt this work
          model_class. 
            where.not(target_table => {deep_import_id: nil}). # TODO: add batch/process id
            joins( # TODO: remove need for ON clause
              "JOIN #{index_table} ON #{target_table}.deep_import_id = #{index_table}.deep_import_id"
            ).joins( # TODO: remove need for ON clause
							"JOIN #{associated} ON #{associated}.deep_import_id = #{index_table}.#{names[:deep_import_target_association_id_field]}"
            ).update_all(
              "#{target_table}.#{names[:target_association_id_field]} = #{associated}.id"
            )
=end
    end

		def mysql2_association_logic( names )
      "
				UPDATE
					#{names[:target_table]} AS target_table
				JOIN 
					#{names[:deep_import_target_table]} AS deep_import_index
				ON 
					target_table.deep_import_id = deep_import_index.deep_import_id 
				AND
					NOT ISNULL(target_table.deep_import_id)
				JOIN 
					#{names[:association_table]} AS belongs_to_table
				ON 
					deep_import_index.#{names[:deep_import_target_association_id_field]} = belongs_to_table.deep_import_id
				SET
					target_table.#{names[:target_association_id_field]} = belongs_to_table.id
      "
		end

		def postgresql_association_logic( names )
      "
				UPDATE 
					#{names[:target_table]} AS target_table
				SET
					#{names[:target_association_id_field]} = belongs_to_table.id
				FROM
					#{names[:deep_import_target_table]} AS deep_import_index,
					#{names[:association_table]} AS belongs_to_table 
				WHERE
					target_table.deep_import_id = deep_import_index.deep_import_id 
				AND
					deep_import_index.#{names[:deep_import_target_association_id_field]} = belongs_to_table.deep_import_id
				AND
					target_table.deep_import_id NOTNULL
      "
		end

		def model_names( model_class, parent_class )
			{
				:target_table => model_class.to_s.underscore.pluralize,
				:target_association_id_field => "#{parent_class}_id",
				:deep_import_target_association_id_field => "deep_import_#{parent_class}_id",
				:association_table => parent_class.to_s.pluralize,
				:deep_import_target_table => "deep_import_#{model_class}".underscore.pluralize
			}
		end

    def execute(sql)
			ActiveRecord::Base.connection.execute(sql)
    end

    def adapter
      @adapter ||= ActiveRecord::Base.connection_config[:adapter]
    end

		def import_models
			DeepImport::Config.importable.each do |base_class|
				[ base_class, "DeepImport#{base_class}".constantize ].each do |model_class|
					instances = DeepImport::ModelsCache.cached_instances( model_class )
          next if instances.empty?
          @imported[model_class] = true

					raise "#{model_class} does not respond to import" unless model_class.respond_to? :import, true # somewhat unnecessary safety check
					results = nil
          DeepImport.log_time("commit.import(#{model_class})") { results = model_class.import(instances) }
					if results.failed_instances.size > 0
						raise "Error Inserting #{model_class}, #{results.failed_instances.size}/#{instances.size} failures. Failed Instances: #{results.failed_instances.to_yaml}"
					end

				end
			end

		end

	end
end

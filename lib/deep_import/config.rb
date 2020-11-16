module DeepImport

	class Config
		attr_reader :models, :status

		def self.models
			raise "@@models has not yet been defined yet" if @@models.nil?
			@@models
		end

		def initialize
      # Driven by file config
      # TODO: orrrrr, drive off info in models

			@models = Hash.new
      begin
        parse_config
        parse_models # from config
        @status = :valid
      rescue Exception => e
				DeepImport.logger.error "DeepImport: Failed to parse models."
				DeepImport.logger.error "DeepImport: Config: \n#{@config.to_yaml}"
				DeepImport.logger.error "DeepImport: Unable to initialize."
        #raise e # dont raise - allow rails to work normally/prevents hard crashes from bad configs
      end
			@@models = valid? ? @models : Hash.new
		end

		def valid?
			@status == :valid
		end

		private

    def parse_config
      if $deep_import_config.present? # Testing Helper/In Memory
        @config = $deep_import_config
      else # File based
        cf = ENV["DEEP_IMPORT_CONFIG"] || File.join(".", "config", "deep_import.yml")
        parse_config_file(cf)
      end
    end

		def parse_config_file(config_file)
			begin
        raise "Missing config file: #{config_file}" unless File.file?(config_file)
        @config = YAML.load_file config_file
			rescue Exception => e
				DeepImport.logger.error "DeepImport: Failed to parse config: #{config_file}"
        raise e
			end
		end

		def parse_models
		  raise "Config object not a Hash, #{@config.class}" if !@config.is_a? Hash

			@config.each do |model_name,info|
				model_class = class_for model_name
				parse_model_associations( model_class, info )
			end
		end

		def	parse_model_associations( model_class, info )
			@models[ model_class ] ||= Hash.new
			associations.each do |association| 
        @models[ model_class ][ association ] ||= Hash.new 
      end

			return if info.nil? # this is a root class, no associations of note
			raise "Info for #{model_class} expected as Hash, not: #{info.to_yaml}" unless info.is_a? Hash

			info.each do |association_type,related_models|
				parse_model_association( model_class, association_type, related_models )
			end
		end

		def associations
      # Note: has_one/many, we only need to worry about the belongs
			[ :belongs_to ]
		end

		def association_symbol( association_string )
			raise "Association is not a string: #{association_string.class}, #{association_string}" unless association_string.is_a? String
			association_type = association_string.to_sym
			raise "Invalid association type: #{association_type}" unless associations.include? association_type
			association_type
		end

		def parse_model_association( model_class, association_type, related_models )
			type_sym = association_symbol( association_type )
			if related_models.is_a? String
				add_association( model_class, related_models, type_sym )
			elsif related_models.is_a? Array 
				related_models.each {|related_model|  add_association( model_class, related_model, type_sym ) }
			else
				raise "Unknown related_models class, (#{related_models.class}): #{related_models.to_yaml}"
			end
		end

		def add_association( model_class, related_model, association_type )
			related_class = class_for related_model
			# this is a Hash in order to support deeper configuration with keywords like polymorphic
			# for the time being this is the truth 
			@models[ model_class ][ association_type ][ related_class ] = true
		end

		def class_for( model_name )
			raise "Model Name Not A String: #{model_name.class}, #{model_name}" unless model_name.is_a? String
			model_class = model_name.to_s.singularize.classify.constantize
			raise "Model not in singular class name form: Parsed(#{model_name}) vs Expected(#{model_class})" if model_name != model_class.to_s
			model_class
		end


	end

end

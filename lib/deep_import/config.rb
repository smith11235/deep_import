module DeepImport

	class Config
		attr_reader :models, :status

		def self.models
			raise "@@models has not yet been defined yet" if @@models.nil?
			@@models
		end

		def initialize
			@config_file_path = File.join( Rails.root, "config", "deep_import.yml" )
			parse

			@@models = @models if valid?
		end

		def valid?
			return @status == :valid
		end

		def parse
			return unless parse_config_file
			@status = :parsed
			return unless parse_models
			@status = :valid
		end

		private

		def parse_config_file
			if ! File.file? @config_file_path
				puts "Missing config file"
				@status = :inactive
				DeepImport.logger.info "DeepImport: No #{@config_file_path}"
				return false
			end

			begin
				@config = YAML::load File.open( @config_file_path, "r" )
			rescue Exception => e
				@status = :error
				DeepImport.logger.error "Deep Import: parsing error for #{@config_file_path}"
				DeepImport.logger.error "Exception: #{e.to_yaml}"
				return false
			end

			return true
		end

		def parse_models
			if ! @config.is_a? Hash
				@status = :error
				DeepImport.logger.error "Deep Import: config root object not a Hash, #{@config.class}"
				return false
			end

			@models = Hash.new
			begin
				@config.each do |model_name,info|
					model_class = class_for model_name
					parse_model_associations( model_class, info )
				end
			rescue Exception => e
				@status = :error
				DeepImport.logger.error "Deep Import: error parsing models: #{e.to_yaml}"
				DeepImport.logger.error "Backtrace #{e.backtrace}"
				return false
			end
			return true 
		end

		def	parse_model_associations( model_class, info )
			@models[ model_class ] ||= Hash.new
			associations.each {|association| @models[ model_class ][ association ] ||= Hash.new }

			return if info.nil? # this is a root class, no associations of note
			raise "Info for #{model_class} expected as Hash, not: #{info.to_yaml}" unless info.is_a? Hash

			info.each do |association_type,related_models|
				parse_model_association( model_class, association_type, related_models )
			end
		end

		def associations
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

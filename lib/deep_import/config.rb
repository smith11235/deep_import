module DeepImport

	class Config
		attr_reader :models, :status

    def self.importable
      @@importable
    end

    def self.belongs_to(base)
      @@belongs_to[base] || []
    end

    def self.has_many(base)
      @@has_many[base] || []
    end

    def self.polymorphic(base)
      @@polymorphic[base] || []
    end


		def initialize(setup: false)
      @setup = setup

      # Driven by file config or global hash object

			@models = Hash.new
      begin
        parse_config
        parse_models # from config
        @status = :valid
      rescue Exception => e
				DeepImport.logger.error "DeepImport: Config Failure"
				DeepImport.logger.error "DeepImport: Config: file: #{config_file}"
				DeepImport.logger.error "DeepImport: Config: content: #{@config.to_yaml}"
				DeepImport.logger.error "Exception: #{e.message}"
				DeepImport.logger.error "Exception: #{e.backtrace[0, 10].to_yaml}"
        raise e if @setup

        @models = {} # reset to empty - if invalid config - do nothing
        #raise e # dont raise - allow rails to work normally/prevents hard crashes from bad configs
      end

      @@importable = @models.keys.collect{|c| constant(c)}
      @@belongs_to = {}
      @@has_many = {}
      @@polymorphic = {}

      # fill in has_many/belongs_to
      @models.each do |base, relations|
        base = constant(base)
        rels = (relations[:belongs_to] || {}).keys
        @@belongs_to[base] = rels.collect do |belongs| 
          # TODO: add config option for has_one, has_many is default assumption currently
          belongs = constant(belongs)
          # Consider removing has_many here, and expect explicit defs from config
          @@has_many[belongs] ||= []
          @@has_many[belongs] << rel_name(base, plural: true)
          rel_name(belongs)
        end

        # TODO: implement it

        rels = (relations[:has_many] || {}).keys
        rels.each do |rel_class|
          @@has_many[base] ||= []
          rel_plural = rel_name(rel_class, plural: true)
          next if @@has_many[base].include?(rel_plural)
          @@has_many[base] << rel_plural
        end

        rels = (relations[:polymorphic] || {}).keys
        rels.each do |rel_class|
          rel = rel_name(rel_class)
          @@belongs_to[base] ||= []
          @@belongs_to[base] << rel
          @@polymorphic[base] ||= []
          @@polymorphic[base] << rel
        end
      end

		end

    def rel_name(class_s, plural: false)
      rel = class_s.to_s.singularize.underscore
      rel = rel.pluralize if plural
      rel.to_sym
    end

    def constant(class_s)
      class_s = class_s.to_s.singularize
      if @setup
        class_s
      else # live usage - use class constants
        class_s.constantize
      end
    end

    def print_config
      puts "DeepImport Config =================".green
      c = {
        importable: @@importable.map(&:to_s),
        belongs_to: @@belongs_to,
        has_many: @@has_many
      }
      puts c.to_yaml.green
    end


		def valid?
			@status == :valid
		end

		private

    def parse_config
      if $deep_import_config.present? # Testing Helper/In Memory
        @config = $deep_import_config
      else # File based
        parse_config_file
      end
    end

    def config_file
      DeepImport.config_file
    end

		def parse_config_file
			begin
        raise "Missing config file: #{config_file}" unless File.file?(config_file)
        @config = YAML.load_file config_file
			rescue Exception => e
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
			[ :belongs_to, :has_many, :polymorphic ]
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

			model_class = model_name.to_s.singularize.classify 
      # TODO: update code to use Strings everywhere for this
      # Setup/Teardown do not have access to Models
      # confirm all models are valid in Initialize class

      # TODO: should we guarantee singular form in config file, or allow either?
			# raise "Model not in singular class name form: Parsed(#{model_name}) vs Expected(#{model_class})" if model_name != model_class.to_s
			model_class
		end


	end

end

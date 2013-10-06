module DeepImport
	module Config

		def self.setup 
			@@details = ConfigParser.new.parse_model_trees
		end

		def self.deep_import_config
			@@details
		end

		def self.models
			@@details[ :models ]
		end

		private

		class ConfigParser

			def initialize
				config_file_path = File.join( Rails.root, "config", "deep_import.yml" )
				raise "Missing Config File: #{config_file_path}".red unless File.file? config_file_path
				@config = YAML::load File.open( config_file_path )
				@details = { :models => Hash.new, :roots => Array.new }
			end

			def parse_model_trees
				# we expect a hash of root model names to nested model names
				raise "Root object not a hash" unless @config.is_a? Hash
				@config.each do |root_name,info|
					parse_root( root_name, info )
				end
				return @details
			end

			def	parse_root( root_name, info )
				root_class = class_for root_name
				raise "Root model not in singular class name form: Parsed(#{root_name}) vs Expected(#{root_class})" if root_name != root_class.to_s
				raise "root definition expected as a Hash, not a #{info.class}" unless info.is_a? Hash

				if ! @details[:roots].include? root_class
					@details[:roots] << root_class # add this to the roots tracker
					model_defs( root_class ) # setup a models entry for this root
				end

				parse_children( root_class, info )
			end

			def parse_children( parent_class, children )
				children.each do |child_name,child_info|
					# children entries are either nested classes
					# or meta tags on the current parent
					# meta tags are flagged by a leading _
					if child_name =~ /^_/
						parse_flag( parent_class, child_name.clone, child_info )
					else
						parse_child( parent_class, child_name.clone, child_info )
					end
				end
			end

			def class_for( model_name )
				model_name.to_s.singularize.classify.constantize
			end

			def model_defs( class_name )
				model_class = class_for( class_name )
				@details[:models][ model_class ] ||= { :flags => Hash.new,  :belongs_to => Array.new, :has_one => Array.new, :has_many => Array.new } 
				return @details[:models][ model_class ]
			end

			def parse_flag( parent_class, flag_name, flag_info )
				model_defs( parent_class )[ :flags ][ flag_name ] = flag_info
			end

			def parse_child( parent_class, child_name, child_info )
				raise "details of #{child_name} expected as a Hash or nil, not a #{child_info.class}" unless child_info.nil? || child_info.is_a?(Hash)
				child_class = class_for( child_name ) # get class constant

				model_defs = model_defs( child_class ) # get definition to populate with details

				# previous existence chack it to allow multiple model trees
				model_defs[ :belongs_to ] << parent_class if ! model_defs[ :belongs_to ].include? parent_class

				has_type = has_type( child_name ) # is this a :has_one or :has_many relation to the parent class
				model_defs( parent_class )[ has_type ] << child_class unless model_defs( parent_class )[ has_type ].include? child_class

				return if child_info.nil? # if we're on a simple leaf node
				parse_children( child_class, child_info )
			end

			def has_type( child_name )
				case child_name 
				when child_name.singularize 
					:has_one
				when child_name.pluralize 
					:has_many
				else
					raise "Unknown plurality: #{child_name}, Expecting #{child_name.singularize} or #{child_name.pluralize}".red
				end
			end

		end

	end

end

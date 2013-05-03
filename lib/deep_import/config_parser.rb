module DeepImport
	class ConfigParser
	
		def initialize( nests )
			@nests = nests
			@details = { :models => Hash.new, :roots => Array.new }
			#	, :belongs_to => Hash.new, :has_many => Hash.new, :has_one => Hash.new, :generate => Hash.new }
			parse_roots
		end

		def tracking_model_generate_logic
			generate_statements = Hash.new
			@details[:roots].each do |root_name|
				generate_statements[ root_name ] = "Soft#{root_name} soft_id:integer"
			end

			@details[:models].each do |model_name,info|
				generate_statements[ model_name ] ||= "Soft#{model_name} soft_id:integer"

				info[ :belongs_to ].each do |parent_class|
					soft_parent_name = "Soft#{parent_class}".underscore
					generate_statements[ model_name ] << " " << soft_parent_name << ":references" unless generate_statements[ model_name ] =~ /#{soft_parent_name}/ 
				end
			end
			return generate_statements
		end

		def parse_roots
			# we expect a hash of root model names to nested model names
			raise "Root object not a hash" unless @nests.is_a? Hash
			@nests.each do |root_name,info|
				parse_root( root_name, info )
			end
		end

		def	parse_root( root_name, info )
			raise "Root not recognized as singular: #{root_name}" unless root_name == root_name.singularize
			raise "root definition not a Hash of class names" unless info.is_a? Hash

			root_name = root_name.classify

			if ! @details[:roots].include? root_name 
				@details[:roots] << root_name 
				model_defs( root_name )
			end

			parse_children( root_name, info )
		end


		def parse_children( parent_class, children )
			children.each do |child_name,child_info|
				# children entries are either nested classes
				# or meta tags on the current parent
				puts "Examining: #{child_name}"
				if child_name =~ /^_/
					parse_flag( parent_class, child_name.clone, child_info )
				else
					parse_child( parent_class, child_name.clone, child_info )
				end
			end
		end

		def model_defs( class_name )
			@details[:models][ class_name ] ||= { :flags => Hash.new,  :belongs_to => Array.new, :has_one => Array.new, :has_many => Array.new } 
			return @details[:models][ class_name ]
		end

		def parse_flag( parent_class, flag_name, flag_info )
			model_defs( parent_class )[ :flags ][ flag_name ] = flag_info
		end

		def class_words( input_name )
			class_name = input_name.singularize.classify
			class_forms = { :class_string => class_name.classify, :one => class_name.singularize, :many => class_name.pluralize }
			class_forms
		end

		def parse_child( parent_class, child_name, child_info )
			class_forms = class_words( child_name )

			has_type = has_type( child_name, class_forms )
			has_type = "has_#{has_type}".to_sym

		  model_defs = model_defs( class_forms[:class_string] )

			model_defs[ :belongs_to ] << parent_class if ! model_defs[ :belongs_to ].include? parent_class 

			model_defs( parent_class )[ has_type ] << class_forms[:class_string] unless model_defs( parent_class )[ has_type ].include? class_forms[:class_string]

			return if child_info.nil?
			parse_children( class_forms[:class_string], child_info ) if child_info.is_a? Hash
		end

		def has_type( child_name, class_forms )
			case child_name 
			when class_forms[ :one ] 
				:one
			when class_forms[ :many ] 
				:many
			else
				raise "Unknown plurality: #{child_name}".red
			end
		end

	end

end

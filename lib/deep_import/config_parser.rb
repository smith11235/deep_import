module DeepImport
	class ConfigParser
	
		def initialize( nests )
			@nests = nests
			@details = { :models => Hash.new, :roots => Array.new }
		#	, :belongs_to => Hash.new, :has_many => Hash.new, :has_one => Hash.new, :generate => Hash.new }
			parse_roots
			puts @details.to_yaml
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
				@details[:models][ root_name ] ||= { :belongs_to => Array.new, :has_one => Array.new, :has_many => Array.new }
			end

			parse_children( root_name, info )
		end


		def parse_children( parent_class, children )
			children.each do |frozen_child_name,child_info|
				parse_child( parent_class, frozen_child_name.clone, child_info )
			end
		end

		def parse_child( parent_class, child_name, child_info )
			class_forms = { :class_string => child_name.classify, :one => child_name.singularize, :many => child_name.pluralize }

			has_type = has_type( child_name, class_forms )

			# generate statement, new belongs_to references get appended
			# @details[:generate][ @root_class ] ||= "model Soft#{@root} soft_id:integer"
		 	#	"model #{class_forms[:class_string]} soft_id:integer"
			# @details[:generate][ class_forms[:class_string] ] << " " << "Soft#{parent_class}".underscore << "_id:references"
			@details[:models][ class_forms[:class_string] ] ||= { :belongs_to => Array.new, :has_one => Array.new, :has_many => Array.new } 

			@details[:models][ class_forms[:class_string] ][ :belongs_to ] << parent_class if ! @details[:models][ class_forms[:class_string] ][ :belongs_to ].include? parent_class 

			has_type = "has_#{has_type}".to_sym
			@details[:models][ parent_class ][ has_type ] << class_forms[:class_string] unless @details[:models][ parent_class ][ has_type ].include? class_forms[:class_string]

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

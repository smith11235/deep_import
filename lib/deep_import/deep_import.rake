namespace :deep_import do 
	class NestParser
		def initialize( nests )
			@nests = nests
			@details = { :models => Array.new, :roots => Array.new, :belongs_to => Hash.new, :has_many => Hash.new, :has_one => Hash.new, :generate => Hash.new }
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
			@root = root_name # singular form
			@root_class = root_name.classify

			if ! @details[:roots].include? @root
				@details[:roots] << @root
				@details[:generate][ @root_class ] ||= "model Soft#{@root} soft_id:integer"
			end

			parse_children( info )
		end


		def parse_children( children )
			children.each do |frozen_child_name,child_info|
				child_name = frozen_child_name.clone
				class_forms = { :class_string => child_name.classify, :one => child_name.singularize, :many => child_name.pluralize }
				has_type = has_type( child_name, class_forms )

				# generate statement, new belongs_to references get appended
				@details[:generate][ class_forms[:class_string] ] ||= "model #{class_forms[:class_string]} soft_id:integer"
				# collect belongs to relations in an array
				# so an object can have multiple belongs_to associations
				@details[:belongs_to][ class_forms[:class_string] ] ||= Array.new
				if ! @details[:belongs_to][ class_forms[:class_string] ].include? @root
					@details[:belongs_to][ class_forms[:class_string] ] << @root 
					@details[:generate][ class_forms[:class_string] ] << " Soft#{@root}_id:references"
				end

				# has_(many|one) relationships
				@details["has_#{has_type}".to_sym][ class_forms[:class_string] ] ||= Array.new
				@details["has_#{has_type}".to_sym][ class_forms[:class_string] ] << @root unless  @details["has_#{has_type}".to_sym][ class_forms[:class_string] ].include? @root

				# todo: remainder of atts
			end
		end

		def parse_child
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

		def space
			"  " * @indent
		end

		def indent( level = nil )
			@indent = level unless level.nil?
			@indent += 1
			yield
			@indent -= 1
		end
	end

	desc "Create migrations based on config/deep_import.yml"
	task :setup => :environment do 
		puts "Welcome to DeepImport:".green
		config_file_path = File.join( Rails.root, "config", "deep_import.yml" )
		raise "Missing Config File: #{config_file_path}".red unless File.file? config_file_path
		nests = YAML::load File.open( config_file_path )
		NestParser.new( nests )
	end
end

namespace :deep_import do 
	class NestParser
		def initialize( nests )
			@nests = nests
			parse_roots
		end

		def parse_roots
			raise "Root object not a hash" unless @nests.is_a? Hash
			@nests.each do |root_name,info|
				parse_root( root_name, info )
			end
		end

		def	parse_root( root_name, info )
			@root = root_name
			raise "Root not recognized as singular: #{@root}" unless @root == @root.singularize

			indent(0) do
				raise "root definition not a Hash of class names" unless info.is_a? Hash

				info.each do |frozen_child_name,child_info|
					child_name = frozen_child_name.clone
					class_forms = { :class_string => child_name.classify, :one => child_name.singularize, :many => child_name.pluralize }
					puts "checklist".red
					has_type = case child_name 
										 when class_forms[ :one ] 
											 :one
										 when class_forms[ :many ] 
											 :many
										 else
											 raise "Unknown plurality: #{child_name}".red
										 end

					puts space + "#{class_forms[:class_string]} belongs_to #{@root}"
					puts space + "  # #{@root} has_#{has_type} #{child_name}" 
					puts space + "  generate model Soft#{class_forms[:class_string]} soft_id:integer"
					puts space + " # and get the rest of it's belongs to"
				end
			end
		end

		def parse_child
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

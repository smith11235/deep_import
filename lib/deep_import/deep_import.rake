namespace :deep_import do 
	class NestParser
		def initialize( nests )
			@nests = nests
			parse_roots
		end

		def parse_roots
			raise "Root object not a hash" unless @nests.is_a? Hash
			@nests.each do |plural_name,info|
				@root = plural_name
				indent(0) do
					raise "root definition not an Array" unless info.is_a? Array
					info.each do |child_class|
						puts space + "#{child_class.singularize} belongs_to #{@root}"
						puts space + "  # #{@root} has_many #{child_class}" if child_class == child_class.pluralize
						
					end
				end
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

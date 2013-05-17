namespace :deep_import do 

	desc "Build a fake nested dataset, commit to db"
	task :benchmark => :environment do
		(0..10).each do |parent_name|
			parent = Parent.new( :name => parent_name.to_s )
			(0..10).each do |child_name|
				child = parent.children.new( :name => child_name.to_s )
				(0..10).each do |grand_child_name|
					grand_child = child.grand_children.new( :name => grand_child_name )
				end
			end
		end
		DeepImport.commit
	end

	desc "View"
	task :view => :environment do
		Parent.all.each do |parent|
			puts "Parent: #{parent.id}"
			puts "  - has children: #{parent.children.count}"
			puts "  - has grandchildren: #{parent.grand_children.count}" 
		end
	end

	desc "Create migrations based on config/deep_import.yml"
	task :setup => :environment do 
		puts "Welcome to DeepImport:".green
		DeepImport::Setup.new
	end

	def create_migration( name )
		migration_file = "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{name.underscore}.rb"
		File.open( migration_file, "w" ) do |f|
			f.puts "class #{name} < ActiveRecord::Migration"
			f.puts "  def change"
			yield f
			f.puts "  end"
			f.puts "end"
		end
		puts "Generated: #{migration_file}".yellow
	end

	desc "Add Indicies"
	task :index => :environment do 
		DeepImport::Config.deep_import_config[:models].each do |model_class,info|
			create_migration( "AddDeepImportIdIndexTo#{model_class.to_s.pluralize}" ) do |f|
				f.puts "      add_index :deep_import_id, :id"
			end
			create_migration( "AddDeepImportBelongsToIndiciesToDeepImport#{model_class.to_s.pluralize}" ) do |f|
				info[:belongs_to].each do |belongs_to|
					f.puts "      add_index :deep_import_id, :deep_import_#{belongs_to.to_s.underscore}_id"
				end
			end
		end
	end

end

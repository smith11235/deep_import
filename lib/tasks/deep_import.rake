namespace :deep_import do 
	require 'benchmark'

	desc "Example Deep Import"
	task :example_deep_import => :environment do
		range = ENV["deep_import_example_range"] || 5 
		(0..range).each do |parent_name|
			parent = Parent.new( :name => parent_name.to_s )
			(0..range).each do |child_name|
				child = parent.children.new( :name => child_name.to_s )
				(0..range).each do |grand_child_name|
					grand_child = child.grand_children.new( :name => grand_child_name )
				end
			end
		end
		DeepImport.commit
	end

	desc "Example Standard Syntax Import"
	task :example_standard_import => :environment do
		range = ENV["deep_import_example_range"] || 5 
		ENV["disable_deep_import"] = "1" 
		(0..range).each do |parent_name|
			parent = Parent.create!( :name => parent_name.to_s )
			(0..range).each do |child_name|
				child = parent.children.create!( :name => child_name.to_s )
				(0..range).each do |grand_child_name|
					grand_child = child.grand_children.create!( :name => grand_child_name )
				end
			end
		end
	end

	desc "Build a fake nested dataset, commit to db"
	task :benchmark => :environment do
		Rake::Task["db:reset"].invoke
		ENV["deep_import_example_range"] = 29

		puts Benchmark.measure {
			Rake::Task["example_deep_import"].invoke
		}
		# reset db so both tests have same initial starting point
		Rake::Task["db:reset"].reenable
		Rake::Task["db:reset"].invoke
		puts Benchmark.measure {
			Rake::Task["example_standard_import"].invoke
		}

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
		sleep( 3 )
	end

	desc "Add Indicies"
	task :index => :environment do 
		DeepImport::Config.deep_import_config[:models].each do |model_class,info|
			plural_name = model_class.to_s.pluralize
			table_name = plural_name.underscore

			create_migration( "AddDeepImportIdIndexTo#{plural_name}" ) do |f|
				f.puts "      add_index :#{table_name}, [:deep_import_id, :id], :name => 'di_id_index'"
			end
			create_migration( "AddDeepImportBelongsToIndiciesToDeepImport#{model_class.to_s.pluralize}" ) do |f|
				info[:belongs_to].each do |belongs_to|
					f.puts "      add_index :deep_import_#{table_name}, [:deep_import_id, :deep_import_#{belongs_to.to_s.underscore}_id], :name => 'di_#{belongs_to.to_s.underscore}'"
				end
			end
		end
	end

end

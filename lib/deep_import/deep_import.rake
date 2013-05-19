namespace :deep_import do 
	require 'benchmark'

	namespace :benchmark do
		desc "Example Deep Import"
		task :deep_import => :environment do
			range = ENV["RANGE"].to_s.to_i

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
		task :standard_import => :environment do
			ENV["disable_deep_import"] = "1" 
			range = ENV["RANGE"].to_s.to_i

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
	end

	desc "Build a fake nested dataset, commit to db"
	task :benchmark => :environment do
		ENV["RANGE"] ||= "4"
		# reset database for deep import test
		Rake::Task["db:reset"].invoke
		# run deep import test
		puts Benchmark.measure {
			Rake::Task["deep_import:benchmark:deep_import"].invoke
		}

		# reset database for standard test
		Rake::Task["db:reset"].reenable
		Rake::Task["db:reset"].invoke
		# run standard test
		puts Benchmark.measure {
			Rake::Task["deep_import:benchmark:standard_import"].invoke
		}

	end

	desc "Create migrations based on config/deep_import.yml"
	task :setup do 
		ENV["deep_import_disable_railtie"] = "1"
		Rake::Task["deep_import:setup:teardown"].invoke
		Rake::Task["deep_import:setup:setup"].invoke
	end

	namespace :setup do
		task :teardown do 
			generated_files = Dir.glob( "app/models/deep_import_*.rb" ) + Dir.glob( "db/migrate/*_deep_import_*.rb" )
			generated_files.each do |file|
				puts "Removing: #{file}"
				FileUtils.rm( file )
			end
		end

		task :setup_internal => :environment do
			DeepImport::Setup.new
		end
	end

end

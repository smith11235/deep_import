namespace :deep_import do 
	require 'benchmark'

	desc "Example Deep Import"
	task :example_deep_import => :environment do
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
	task :example_standard_import => :environment do
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

	desc "Build a fake nested dataset, commit to db"
	task :benchmark => :environment do
		# reset database for deep import test
		Rake::Task["db:reset"].invoke
		# run deep import test
		puts Benchmark.measure {
			Rake::Task["example_deep_import"].invoke
		}

		# reset database for standard test
		Rake::Task["db:reset"].reenable
		Rake::Task["db:reset"].invoke
		# run standard test
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
		%w(DeepImportParent DeepImportChild DeepImportGrandChild).each do |deep_class_name|
			puts "#{deep_class_name}: #{deep_class_name.constantize.count}"
		end
	end

	desc "Create migrations based on config/deep_import.yml"
	task :setup => :environment do 
		puts "Welcome to DeepImport:".green
		DeepImport::Setup.new
	end


end

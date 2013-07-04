require 'benchmark'

desc "Associations Examples"
task :associations => :environment do

	parents = (0..1).collect {|i| Parent.new( :name => "#{i}" ) }
	children = (0..3).collect do |i| 
		child = Child.new( :name => "#{i}" )
		child.parent = parents[ i % 2 ]
		child
	end

	grand_children = (0..7).collect do |i|
		grand_child = GrandChild.new( :name => "#{i}" ) 
		grand_child.child = children[ i % 4 ]
		grand_child
	end

	puts children.to_yaml.yellow

	# save

end

desc "Build a fake dataset with and without deep_import"
task :benchmark => :environment do
	ENV["RANGE"] ||= "4" # creates range * range * range models
	['deep_import','standard_import'].each do |task|
		# clear database for uniform initial conditions
		Rake::Task["db:reset"].reenable
		Rake::Task["db:reset"].invoke
		puts "#{task}: #{Benchmark.measure { Rake::Task["benchmark:#{task}"].invoke } }"
	end
end

namespace :benchmark do
	desc "Example Data Set Creation With Deep Import"
	task :deep_import => :environment do
		DeepImport.logger = Logger.new(STDOUT)
		range = ( ENV["RANGE"] || "1" ).to_i

		(0..range).each do |parent_name|
			parent = Parent.new( :name => parent_name.to_s ) # new, or build, not create
			(0..range).each do |child_name|
				child = parent.children.new( :name => child_name.to_s )
				(0..range).each do |grand_child_name|
					grand_child = child.grand_children.new( :name => grand_child_name.to_s )
				end
			end
		end
		DeepImport.commit # save all models to database
	end

	desc "Example Rails Standard Syntax Import Without Deep Import"
	task :standard_import => :environment do
		ENV["disable_deep_import"] = "1" 
		range = ( ENV["RANGE"] || "1" ).to_i

		(0..range).each do |parent_name|
			parent = Parent.create!( :name => parent_name.to_s ) # create instead of build
			(0..range).each do |child_name|
				child = parent.children.create!( :name => child_name.to_s )
				(0..range).each do |grand_child_name|
					grand_child = child.grand_children.create!( :name => grand_child_name )
				end
			end
		end
	end

end

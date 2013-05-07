namespace :deep_import do 

	desc "Build a fake nested dataset, commit to db"
	task :benchmark => :environment do
		(0..1).each do |parent_name|
			parent = Parent.new( :name => parent_name.to_s )
			(0..1).each do |child_name|
				child = parent.children.new( :name => child_name.to_s )
				(0..1).each do |grand_child_name|
					grand_child = child.grand_children.new( :name => grand_child_name )
				end
			end
		end
		DeepImport.commit
	end

	desc "Create migrations based on config/deep_import.yml"
	task :setup => :environment do 
		puts "Welcome to DeepImport:".green
		DeepImport::Setup.new
	end

end

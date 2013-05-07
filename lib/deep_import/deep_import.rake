namespace :deep_import do 

	desc "Create migrations based on config/deep_import.yml"
	task :setup => :environment do 
		puts "Welcome to DeepImport:".green
		DeepImport::Setup.new
	end

	desc "Build a fake dataset using DummyModels"
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

		puts "Models:"
		DeepImport::ModelsCache.get_cache.each do |model_class,instances|
			puts "- #{model_class}: #{instances.size}"
		end
		# DeepImport.commit
	end

end

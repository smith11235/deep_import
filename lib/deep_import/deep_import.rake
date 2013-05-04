namespace :deep_import do 

	desc "Create migrations based on config/deep_import.yml"
	task :setup => :environment do 
		puts "Welcome to DeepImport:".green
		DeepImport::Setup.new
	end

	desc "Build a fake dataset using DummyModels"
	task :benchmark => :environment do
		(0..1).each_with_index do |root_number,r|
			root_dummy_model = DummyModel.new( :name => "root(#{r})" )
			# dont use create, override it with a raise condition
			(0..1).each_with_index do |child_number,c|
				child_dummy_model = root_dummy_model.build_dummy_model( :name => "child(#{c}) => #{root_dummy_model.name}" )
				puts "Relation from child: #{child_dummy_model.dummy_model} or id: #{child_dummy_model.dummy_model_id}"
			end
			puts "Root children: #{root_dummy_model.dummy_models.to_yaml}"
		end
	end

end

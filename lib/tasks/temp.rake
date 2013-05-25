desc "load environment"
task :load_environment => :environment do
	puts "loaded environment"	
end

desc "View"
task :view => :environment do
	puts "Index: #{ActiveRecord::Base.connection.index_exists? :parents, [:deep_import_id, :id], :name => "di_id_index"}"
	[Parent,Child,GrandChild,DeepImportParent,DeepImportChild,DeepImportGrandChild].each do |class_name|
		puts "#{class_name}: #{class_name.count}"
	end
end



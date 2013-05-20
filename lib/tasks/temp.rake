desc "load environment"
task :load_environment => :environment do
	puts "loaded environment"	
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



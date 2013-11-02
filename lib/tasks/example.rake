desc "Example Deep Import"
task :example => :environment do

	DeepImport.import do
		(0..10).each do |parent_number|
			parent = Parent.new
			(0..10).each do |child_number|
				child = Child.new
				child.parent = parent
				(0..10).each do |grandchild_number|
					grandchild = GrandChild.new
					grandchild.child = child
				end
			end
		end
	end
end

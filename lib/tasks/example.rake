desc "Example Deep Import"
task :example => :environment do

	#	DeepImport.import do
	DeepImport.import( :on_save => :noop ) do
		(0..3).each do |parent_number|
			parent = Parent.new
			parent.save
			(0..1).each do |child_number|
				child = Child.new
				child.parent = parent
				child.save!
				(0..1).each do |grandchild_number|
					grandchild = GrandChild.new
					grandchild.child = child
					grandchild.save!
				end
			end
		end
	end

	DeepImport.import do
		grand_child = GrandChild.new
		child = grand_child.build_child
		parent = child.build_parent
	end
end

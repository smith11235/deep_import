desc "Example Deep Import"
task :example => :environment do
	Rake::Task["db:reset"].invoke

	# example showing belongs_to::other=
	DeepImport.import do
		(0..3).each do |parent_number|
			parent = Parent.new
			(0..1).each do |child_number|
				child = Child.new
				child.parent = parent
				(0..1).each do |grandchild_number|
					grandchild = GrandChild.new
					grandchild.child = child
				end
			end
		end
	end

	DeepImport.import do
		# example showing belongs_to::build_other
		grand_child = GrandChild.new
		child = grand_child.build_child
		parent = child.build_parent
	end
end

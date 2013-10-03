desc "Associations Examples"
task :associations => :environment do

	# construct all the parents into an array/lookup container
	parents = (0..1).collect {|i| Parent.new( :name => "#{i}" ) }
	# then create children and collect them into a lookup container
	children = (0..3).collect do |i| 
		child = Child.new( :name => "#{i}" )
		# setting their association randomly based on construction order
		child.parent = parents[ i % 2 ]
		child
	end
	# then create grandchildren
	grand_children = (0..7).collect do |i|
		grand_child = GrandChild.new( :name => "#{i}" ) 
		# setting their child association radomly based on construction order
		grand_child.child = children[ i % 4 ]
		grand_child
	end
	DeepImport.commit # save all models to database

end


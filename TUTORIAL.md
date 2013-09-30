# Tutorial

### Install Deep Import Gem

- gem deep_import, :git => 'smith11235/deep_import'

### What is config/deep_import.yml

#### Purpose
- used by Deep Import railtie
- configurs what enhancements Deep Import makes to the applications Models
- supports basic active-record associations
	- has_many
	- has_one
	- belongs_to
- allows transaction efficient batched loading of nested data

#### Example Xml Batch Input of Nested Data
Provides a basis for your config/deep_import.yml

    <parents>
     <parent name="Bill" >
      <child name="Alice" />
      <child name="Bob" >
         <grand_child name="George" />
         <grand_child name="Fred" />
       </child>
      </parent>
      <parent name="Mary" >
       <child name="Mike" >
        <grand_child name="Wilma" />
       </child>
       <child name="Ike" >
        <grand_child name="Barney" />
       </child>
      </parent>
    </parents>

#### Example config/deep_import.yml 
Should be based on your data format.

    Parent:
     Children:
      GrandChildren:

Each Parent has_many Children.  Each Child has_many GrandChildren.<br />
Each GrandChild belongs_to a Child.  Each Child belongs_to a Parent.

#### Config Syntax Explanation
Model name formatting is based on active record [conventions](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html)
- Entries are expected in [CamelCase](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-camelize)

- Root entry must be [singular](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-singularize) form.
- has_one relationships are represented in [singular](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-singularize) form.
- has_many relationships are represented in [plural](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-pluralize) form.

#### Running $ rake deep_import:setup
- runs rake deep_import:teardown
- creates a DeepImport<model_name> model for each Model you have in the config
	- these models create an association index in the background
- rake deep_import:teardown can be used to remove them entirely at any time
- they are meant to be ignored by the user/developer
- rerun any time the config has changes

#### Emphasis on Developer Code Familiarity
- Rails is based on convention over configuration
- Any developer should be able to understand any Rails code
- As such, Deep Import is built within the Active Record Association api
	- provides a familiar coding process for the everyday Rails developer
	- ...it would have been simpler to just make an alternative API
		- but not as easily used

#### Sample Data Loader: Implicit Association Tracking
- Depth First Odering 
	- if you create a root object (a Parent)
		- each Child created after is auto-assigned to the last root instance
	- this is temporarily possible because of a hack
		- eventual full integration with the Association api will replace this with a more robust solution

from lib/tasks/benchmark.rake

	range = 4 # 5 parents, 25 children, 125 grand children 
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

#### Sample Data Loader: Random Ordering Through Belongs To
Using the current belongs_to support you can load in any way you wish.
from lib/tasks/benchmark.rake

	# construct all the parents into a lookup container
	parents = (0..1).collect {|i| Parent.new( :name => "#{i}" ) }

	# then create children and collect Children into a lookup container
	children = (0..3).collect do |i| 
		child = Child.new( :name => "#{i}" )
		# setting their association randomly based on construction order
		child.parent = parents[ i % 2 ]
		child
	end

	# then create grandchildren
	grand_children = (0..7).collect do |i|
		grand_child = GrandChild.new( :name => "#{i}" ) 
		# set child association based on construction order
		grand_child.child = children[ i % 4 ]
		grand_child
	end
	DeepImport.commit # save all models to database

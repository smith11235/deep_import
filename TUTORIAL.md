# Tutorial

#### Code Robustness/RSpec
- RSpec/BDD is the development process being used.
- There are currently 170 specifications, with many more planned.

	Finished in 32.74 seconds
	170 examples, 0 failures, 29 pending

#### Install Deep Import Gem

- gem deep_import, :git => 'smith11235/deep_import'

#### What is config/deep_import.yml
- a yaml formatted file of model names involved in batch import process
- used by Deep Import railtie to configure the rails application models
- supports basic active-record associations
	- has_many
	- has_one
	- belongs_to
- structure should be based on data input format

#### Example config/deep_import.yml 
Should be based on your data format.

    Parent:
     Children:
      GrandChildren:

Each Parent has_many Children.  Each Child has_many GrandChildren.<br />
Each GrandChild belongs_to a Child.  Each Child belongs_to a Parent.

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


#### Config Syntax Explanation
Model name formatting is based on active record [conventions](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html)
- Entries are expected in [CamelCase](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-camelize)

- Root entry must be [singular](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-singularize) form.
- has_one relationships are represented in [singular](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-singularize) form.
- has_many relationships are represented in [plural](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-pluralize) form.

#### rake deep_import:setup && rake deep_import:teardown
- setup
	- creates a DeepImport<model_name> model for each Model in config/deep_import.yml 
		- these are responsible for the model association tracking
		- meant to be ignored by the user, background items
	- generates a single migration
	- runs teardown as a prerequisite
	- rerun any time the config has changed
- teardown
	- removes DeepImport* models
	- removes DeepImport migration

#### Emphasis on Developer Code Familiarity
- Rails is based on convention over configuration
- Any developer should be able to understand any Rails code
- As such, Deep Import is built within the Active Record Association api
	- provides a familiar coding process for the everyday Rails developer
	- ...it would have been simpler to just make an alternative API
		- but not as easily used

#### Sample Data Loader: Implicit Tracking
- Until full API integration is finished this is implemented only through a hack
	- illustrates simple code/process
	- illustrates 'nested data' format
- Depth First Odering Hack
	- if you create a root object (a Parent)
		- each Child created after is auto-assigned to the last root instance
	- full association API integration will replace this

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

#### Sample Data Loader: Random Ordering: belongs_to
Using the current belongs_to support you can load in any manner you wish.<br />
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

# Tutorial

### Install Deep Import Gem

- gem deep_import, :git => 'smith11235/deep_import'

### What is config/deep_import.yml

#### Purpose
- used by Deep Import railtie initialization plugin
	- lib/deep_import/railtie.rb
	- lib/deep_import/initializer.rb
- specifies which models should be enhanced by Deep Import
- defines has_one and has_many relationships
	- using standard ActiveRecord model/table naming conventions
- Allows implicit association tracking
	- using very simple code
	- current support is through a hack
		- if models are loaded in DFS ordering
	- eventual support will be through full API integration

#### Example Xml Batch Input of Nested Data
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
Will generate several new migrations and models.
These models create a shadow index to track the associations within your data.
They can be removed by running rake deep_import:teardown
- they are meant to be ignored by you
- run rake deep_import:setup anytime there are significant changes to the config

#### Sample Data Loader: DFS ordering
Eventually support for has_many will make it so any data loading process will work.
Until then a simple hack has been made that allows implicit association tracking using
- Depth First Odering
	- if you create a root object (a Parent)
		- each Child created after is auto-assigned to the last root instance

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

#### Sample Data Loader: Random Ordering
Using the current belongs_to support you can load in any way you wish.
from lib/tasks/benchmark.rake

	parents = (0..1).collect {|i| Parent.new( :name => "#{i}" ) }
	children = (0..3).collect do |i| 
		child = Child.new( :name => "#{i}" )
		child.parent = parents[ i % 2 ]
		child
	end

	grand_children = (0..7).collect do |i|
		grand_child = GrandChild.new( :name => "#{i}" ) 
		grand_child.child = children[ i % 4 ]
		grand_child
	end

	DeepImport.commit # save all models to database

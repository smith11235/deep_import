# Tutorial


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

#### Sample Data Loader: belongs_to support
Using the current belongs_to support you can load in any manner you wish.<br />
from lib/tasks/benchmark.rake

	range = 4 # 5 parents, 25 children, 125 grand children 
	(0..range).each do |parent_name|
		parent = Parent.new( :name => parent_name.to_s ) # new, or build, not create
		(0..range).each do |child_name|
			child = Child.new( :name => child_name.to_s )
			child.parent = parent
			(0..range).each do |grand_child_name|
				grand_child = GrandChild.new( :name => grand_child_name.to_s )
				grand_child.child = child
			end
		end
	end
	DeepImport.commit # save all models to database

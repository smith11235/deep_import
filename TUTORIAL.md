# Tutorial

## Install Deep Import Gem

- gem deep_import, :git => 'smith11235/deep_import'

## What is config/deep_import.yml

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
Root entry must be singular form.
Entries are expected in CamelCase as per ruby class name convention.
Entries specified in singular form represent 'has_one' relationships.
Entries specified in a plural form represent 'has_one' relationships.
Singular and Plural forms can be understood by following [this](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html)
- [camelize](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-camelize)
- [singularize](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-singularize)
- [pluralize](http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-pluralize)

#### Running $ rake deep_import:setup
Will generate several new migrations and models.
These models create a shadow index to track the associations within your data.
They can be removed by running rake deep_import:teardown

#### Sample Data Loader: DFS ordering
	- in lib/tasks/benchmark.rake
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

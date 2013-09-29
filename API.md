API (How Rails Is Modified)
===========================
The deep_import modifications to Rails are based on [this](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html)

Generally covered are the methods ActiveReocrd provides for associations.
This means anything supporting:
- has_many
- has_one
- belongs_to

For the examples, consider the example models:
- Parent
	- has_many: Children
- Child
	- belongs_to: Parent

Functionality is developed with TDD using RSpec.
Specs can be found in the usual place, spec/**

has_one And belongs_to
----------------------
Current level of support allows easy development supporting a specific pattern in combination with the config file.

Follow the TUTORIAL.md for instructions on how to use deep_import.

Once the full association API has been supported, batch loading should become seemless for a Rails developer.

##### Supported 
- other= instance
- build_other( attributes = {} ) 
- create_other( attributes = {} ) # disabled
- create_other!( attributes = {} ) # disabled


has_many
--------
##### Saddly still unsupported
i have not found the trick yet, but I know I am close
- parent.children.build: in development
- parent.childrens.create(!): redirect through build
- parent.childrens.push: add support logic
- parent.childrens<<: add support logic
- parent.childrens.concat: add support logic
- parent.childrens=(other,other,...): add support logic
- parent.children_ids=   
- parent.children.clear 
- parent.children.delete 
- parent.children.delete_all 
- parent.children.destroy
- parent.children.destroy_all
- parent.children.reset


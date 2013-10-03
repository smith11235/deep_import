API (How Rails Is Modified)
===========================
The deep_import modifications to Rails are based on [this](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html)

Generally covered are the methods ActiveReocrd provides for associations.
This means anything supporting:
- has_many
- has_one
- belongs_to 

Supported Usage
---------------
The goal is complete coverage of the Association api to provide complete confidence to Deep Import users.
* Currently only belongs_to associations work
Instructions for DeepImport and belongs_to import patterns can be found in TUTORIAL.md.

Models used in the examples
------------------------------
- Parent
	- has_many: Children
- Child
	- belongs_to: Parent

polymorphism 
------------
Unsupported currently.

has_one And belongs_to
----------------------

##### Supported: has_one perspective
- parent.child= 
- parent.build_child( attributes = {} ) 
- parent.create_child( attributes = {} ) # disabled
- parent.create_child!( attributes = {} ) # disabled

##### Supported: belongs_to perspective
- child.parent= 
- child.build_parent( attributes = {} ) 
- child.create_parent( attributes = {} ) # disabled
- child.create_parent!( attributes = {} ) # disabled

These are overridden by calling 'method_override' and redefining the methods.

has_many
--------
##### Saddly still unsupported
I have not found the trick yet, but I know I am close.
- parent.children.build: in development
- parent.children.create(!): redirect through build
- parent.children.push: add support logic
- parent.children<<: add support logic
- parent.children.concat: add support logic
- parent.children=(other,other,...): add support logic
- parent.children_ids=   
- parent.children.clear 
- parent.children.delete 
- parent.children.delete_all 
- parent.children.destroy
- parent.children.destroy_all
- parent.children.reset


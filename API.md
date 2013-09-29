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

has_many
--------
##### supported
- parent.children.build  

##### saddly still unsupported
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

has_one AND belongs_to
	endabled:
	- other= instance # done
	- build_other( attributes = {} ) # 
	- create_other( attributes = {} ) # disable # done
	- create_other!( attributes = {} ) # disable # done

=begin
	Method construction methods that create the
	- has_one
	- belongs_to
	association methods
=end


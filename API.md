API (How Rails Is Modified)
===========================
The deep_import modifications to Rails are based on [this](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html)

Generally covered are the methods ActiveReocrd provides for associations.
This means anything for:
* has_many
* has_one
* belongs_to

has_many
---
	endable:
	- others.build  
	- others.create(!) # use build
	- others.push 

	- others<< 
	- others.concat 

	- others=(other,other,...) 

	disable: # this is a load environment, these are disabled, learn to use it, see docs
	- other_ids=   
	- clear 
	- delete 
	- delete_all 
	- destroy
	- destroy_all
	- reset

=begin
	helper methods for has_many associations
=end
=begin
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


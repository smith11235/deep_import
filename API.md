API (How Rails Is Modified)
===========================
The deep_import modifications to Rails are based on the following 
[DOCUMENTATION](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html)


# has_many, has_one, belongs_to association methods

=begin
has_many:
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
=end
			def setup_has_many_association_for( has_many_class )
				puts "Setup #{self}.has_many #{has_many_class}".yellow
				# all these methods have ownership, but set the deep import on the belongs to class
				# similar to  :has_one
				# setup_method_others_dot_build( has_many_class )
			end


=begin
	helper methods for has_many associations
=end
	def setup_method_others_dot_build( other_class )
		override_method( "#{other_class.to_s.underscore.pluralize}.build" ) do |attributes = {}| 
			# build a new method with this method
			other_instance = send inner_method_name, attributes # call the orriginal logic to run normal logic

 	  	DeepImport::ModelsCache.set_association_on( other_instance, self )
			return other_instance

		end
	end

	def override_method( method_name, &method_logic_block )
		method_name = method_name.to_sym if method_name.is_a? String # usage helper
		# validation
		raise "Method Name is not a symbol or string: class: #{method_name.class} value: #{method_name.to_yaml}" unless method_name.is_a? Symbol
		# now we're going to
		# alias the method to a new name
		# and redefine the method name to use the passed in block

		# question: is this exposed to the block here?

		# alias this method to a new method name
		inner_method_name =	method_override_for( method_name ) 

	  # define the new method logic passed in the block
		send :define_method, method_name, method_logic_block
	end


=begin
has_one AND belongs_to
	endabled:
	- other= instance # done
	- build_other( attributes = {} ) # 
	- create_other( attributes = {} ) # disable # done
	- create_other!( attributes = {} ) # disable # done
=end

			def	setup_has_one_association_for( other_class )
				setup_method_other = other_class, :has_one 
				setup_method_create_other( other_class, :has_one  ) # also does create_other!
				setup_method_build_other( other_class, :has_one  ) 
			end

			def	setup_belongs_to_association_for( other_class )
				setup_method_other = other_class, :belongs_to 
				setup_method_create_other( other_class, :belongs_to  ) # also does create_other!
				setup_method_build_other( other_class, :belongs_to  ) 
			end


=begin
	Method construction methods that create the
	- has_one
	- belongs_to
	association methods
=end

				#- belongs_to
				# self.other = 
				# self.create_other
				# self.build_other
		- child.parent = random_parent
			- benchmark/associations
					- for each model with has_many:
						- others<< 
						- others.push  
						- others.concat 
						- others.build  
						- others.create # use build
						- others.create! # use build
						- disable:
							- others=(other,other,...) # not implemented yet
							- other_ids=  # not relevant with deep_import
							- .clear
							- .delete
							- .delete_all
							- .destroy
							- .destroy_all
							- .reset

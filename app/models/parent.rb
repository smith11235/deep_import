class Parent < ActiveRecord::Base
  attr_accessible :name
	has_many :children
	has_many :grand_children, :through => :children
end

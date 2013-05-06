class Child < ActiveRecord::Base
  belongs_to :parent
	has_many :grand_children
  attr_accessible :name
end

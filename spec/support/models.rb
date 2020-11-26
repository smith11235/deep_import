# Test Models: AKA: From User App/Rails
class Parent < ActiveRecord::Base
  has_many :children
end
class Child < ActiveRecord::Base
  belongs_to :parent
  has_many :grand_children
end
class GrandChild < ActiveRecord::Base
  belongs_to :child
end

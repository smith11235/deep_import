# Test Models: AKA: From User App/Rails
class InLaw < ActiveRecord::Base
  belongs_to :relation, polymorphic: true
end

class Parent < ActiveRecord::Base
  has_many :children
  has_many :in_laws, as: :relation
end

class Child < ActiveRecord::Base
  belongs_to :parent
  has_many :grand_children
  has_many :in_laws, as: :relation
end

class GrandChild < ActiveRecord::Base
  belongs_to :child
  has_many :in_laws, as: :relation
end

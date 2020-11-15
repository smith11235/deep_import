class Child < ApplicationRecord
  belongs_to :parent
  has_many :grand_children
end

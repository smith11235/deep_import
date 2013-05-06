class GrandChild < ActiveRecord::Base
  belongs_to :child
  attr_accessible :name
end

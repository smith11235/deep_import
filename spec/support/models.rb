# Test Classes for RSPEC
# TODO: handle dynamically - better setup vs post setup testing

# Base Models - From User App/Rails
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

# DeepImport Models - Post Setup
class DeepImportParent < ActiveRecord::Base
end
class DeepImportChild < ActiveRecord::Base
end
class DeepImportGrandChild < ActiveRecord::Base
end

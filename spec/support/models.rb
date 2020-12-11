# Test Models: AKA: From User App/Rails
class InLaw < ActiveRecord::Base
  include DeepImport::Importable
  belongs_to :relation, polymorphic: true
end

class Parent < ActiveRecord::Base
  include DeepImport::Importable
  has_many :children, extend: DeepImport::HasMany
  has_many :in_laws, as: :relation, extend: DeepImport::HasMany
end

class Child < ActiveRecord::Base
  include DeepImport::Importable
  belongs_to :parent
  has_many :grand_children, extend: DeepImport::HasMany
  has_many :in_laws, as: :relation, extend: DeepImport::HasMany
end

class GrandChild < ActiveRecord::Base
  include DeepImport::Importable
  belongs_to :child
  has_many :in_laws, as: :relation, extend: DeepImport::HasMany
end

class DeepImportChild < ActiveRecord::Base
  attr_accessible :deep_import_id, :parsed_at
  attr_accessible :deep_import_parent_id
end

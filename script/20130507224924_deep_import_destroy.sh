rails destroy migration AddDeepImportIdToParents deep_import_id:string
rails destroy model DeepImportParent deep_import_id:string parsed_at:datetime
rails destroy migration AddDeepImportIdToChildren deep_import_id:string
rails destroy model DeepImportChild deep_import_id:string parsed_at:datetime deep_import_parent_id:string
rails destroy migration AddDeepImportIdToGrandChildren deep_import_id:string
rails destroy model DeepImportGrandChild deep_import_id:string parsed_at:datetime deep_import_child_id:string
module DeepImport
  def self.allow_commit? # TODO: move to deep_import.rb
    # True = make normal save calls
    # False = noop (save) or redirect (create => build)
    # Error = if importing and raise error
    if DeepImport.importing?
      if DeepImport.raise_error? 
        raise "DeepImport: commit method called within import block - change code or pass 'on_save: :noop'"
      else
        false
      end
    else
      true
    end
  end

  module Importable
    def self.included(base) 
      base.class_eval do
        prepend DeepImport::Saveable # override model.save and model.save!
        after_initialize :deep_import_after_initialize_add_to_cache
      end

      # Define index class for deep import tracking/relative ids
      deep_model_class = "DeepImport#{base}"
      Object.const_set(
        deep_model_class, 
        Class.new(ActiveRecord::Base)
      )
    end

    def deep_import_after_initialize_add_to_cache
      # For all trackable classes
      return unless DeepImport.importing? # only during imports
      return unless self.new_record? # must be a new record, other wise ignore
      return unless self.deep_import_id.nil? # must not have been setup already for tracking

      DeepImport::ModelsCache.add(self) # add to cache/set new import id

      # Track associations passed into constructor, track them
      # TODO: can this be improved on? 
      belongs = DeepImport::Config.belongs_to(self.class)
      belongs.each do |other_name|
        other_instance = self.send(other_name)
        next unless other_instance
        DeepImport::ModelsCache.set_association_on(self, other_instance) 
      end
    end
  end
end

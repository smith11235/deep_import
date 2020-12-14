module DeepImport 
  module HasMany
    # TODO: def :<<

    def create(attributes = {})
      if DeepImport.allow_commit?
        super(attributes)
      else
        build(attributes)
      end
    end

    def create!(attributes = {})
      if DeepImport.allow_commit?
        super(attributes)
      else
        build(attributes)
      end
    end

    def build(attributes = {})
      other_instance = super(attributes)
      if DeepImport.importing?
        # polymorphic association - the belongs_to side is re-labeled
        # otherwise, it is simply the class name of the owner
        as = proxy_association.reflection.options[:as] || proxy_association.owner.class
        # TODO: do we need to check for other options like :class_name

        DeepImport::ModelsCache.set_association_on(other_instance, proxy_association.owner, as)
      end
      other_instance 
    end

  end
end

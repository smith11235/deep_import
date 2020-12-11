module DeepImport 
  module HasMany

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
        DeepImport::ModelsCache.set_association_on(other_instance, proxy_association.owner) 
      end
      other_instance 
    end

  end
end

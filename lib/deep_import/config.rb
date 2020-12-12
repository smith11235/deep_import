module DeepImport

	class Config
    @@importable = []
    @@belongs_to = {}
    @@polymorphic = {}

    def self.importable
      @@importable
    end

    def self.belongs_to(base)
      @@belongs_to[base] || []
    end

    def self.polymorphic(base)
      @@polymorphic[base] || []
    end

    def self.add_belongs_to import_class, other_class, polymorphic: false
      @@belongs_to[import_class] ||= []
      @@belongs_to[import_class] << other_class
      if polymorphic
        @@polymorphic[import_class] ||= []
        @@polymorphic[import_class] << other_class
      end
    end

	end

end

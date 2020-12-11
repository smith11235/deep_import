module DeepImport
  # Note: For consistency, it would be nice if belongs_to were extendable similar to has_many
  # AKA: belongs_to :parent, extend: DeepImport::BelongsTo

  # TODO: migrate config usage to be calls from class directly - eliminate config entirely
  # deep_import_belongs_to(OtherClass)

  module BelongsTo

    def self.included(base) # :nodoc:
      base.class_eval do
        prepend BelongsToImportable

        # TODO: move to Importable, remove need for "BelongsTo" include
        def self.setup_belongs_to_for_import(base)
          base.class_eval do
            belongs = DeepImport::Config.belongs_to(base) # TODO: or, self?
            return if belongs.empty?
            belongs.each do |other_name|
              #TODO: deep_import_belongs_to(other_name)
              BelongsToImportable.define_assigns other_name # self.other=
              BelongsToImportable.define_build other_name   # self.build_other(attrs)
              BelongsToImportable.define_create other_name  # self.create_other[!](attrs)
            end
          end
        end

      end
    end


    module BelongsToImportable

      def self.define_assigns other_name
        # aka: child.parent = parent
        send :define_method, "#{other_name}=".to_sym do |other_instance|
          super(other_instance) # call original self.other_name =
          return other_instance if deep_import_id.nil? || !DeepImport.importing?
          # ^ bulk assignment calls 'other=', before deep import id is created....
          # ignore association tracking until an id has been assigned, then add tracking (from after_initialize)
          DeepImport::ModelsCache.set_association_on(self, other_instance) 
          other_instance
        end
      end
  
      def self.define_build other_name
        # aka: child.build_parent(attrs)
        send :define_method, "build_#{other_name}".to_sym do |attributes = {}| 
          # TODO: potentially do "attributes.merge self.class => self", rather than needing import block
          other_instance = super(attributes) 
          if DeepImport.importing? # tricker deep import association tracking
            other_method = "#{other_instance.class.to_s.underscore}=".to_sym
            send other_method, other_instance
          end
          return other_instance
        end
      end
  
      def self.define_create other_name
        # aka: child.create_parent(!)
        [ "", "!" ].each do |exclamation|
          method_name = "create_#{other_name}#{exclamation}".to_sym
          send :define_method, method_name do |attributes = {}| 
            if DeepImport.allow_commit?
              super(attributes)
            else # redirect to build
              build_method = __method__.to_s.gsub(/create/, 'build').gsub(/!/, '')
              send(build_method, attributes)
            end
          end
        end
      end
    end
  end
end

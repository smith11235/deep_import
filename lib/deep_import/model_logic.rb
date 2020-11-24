module DeepImport 
=begin
  http://guides.rubyonrails.org/association_basics.html#association-extensions
  https://gist.github.com/bigfive/1399762
  meta-programming reference: http://www.vitarara.org/cms/ruby_metaprogamming_declaratively_adding_methods_to_a_class
  on tweaking rails: http://errtheblog.com/posts/18-accessor-missing
  on rails model callbacks: http://guides.rubyonrails.org/active_record_validations_callbacks.html#after_initialize-and-after_find
      # we are overriding all appropriate methods generated by:
      # http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
      # has_many, has_one, belongs_to association methods


  # New Blogs
  # https://littlelines.com/blog/2018/01/31/replace-alias-method-chain
=end


  # Common safety guard for Save methods vs No-Op option 
  def self.deep_import_safety_check(method)
    if !DeepImport.importing?
      yield # not in import block, do standard normal call
    elsif DeepImport.raise_error? 
      raise "DeepImport: '#{method}' called within import block - change code or pass 'on_save: :noop'"
    else
      # :noop - ignore call, keep processing - TODO: logger.info?
      # TODO: use from HasMany - redirect create => build
    end
  end

  module ModelLogic

    def self.included(base) # :nodoc:
      # TODO: already initialized safety check
      DeepImport.logger.info "DeepImport::ModelLogic: Extending #{base}".green
      base.class_eval do

        prepend Saveable # override model.save and model.save!

        belongs = DeepImport::Config.belongs_to(self)
        if belongs.size > 0
          prepend BelongsTo 
          belongs.each do |other_name|
            BelongsTo.define_assigns other_name # self.other=
            BelongsTo.define_build other_name   # self.build_other(attrs)
            BelongsTo.define_create other_name  # self.create_other[!](attrs)
          end
        end

        has_many = DeepImport::Config.has_many(self)
        if has_many && has_many.size > 0
          has_many.each do |other_name|
            has_many other_name.to_s.pluralize.to_sym, extend: HasMany
            # TODO: does this eliminate prior settings
          end
        end

        # TODO: add belongs_to DeepImport{self} - Use it to improve commit logic/no SQL
        after_initialize :deep_import_after_initialize # For all tracked classes
      end
    end

    def deep_import_after_initialize
      # For all trackable classes
      return unless DeepImport.importing? # only during imports
      return unless self.new_record? # must be a new record, other wise ignore
      return unless self.deep_import_id.nil? # must not have been setup already for tracking

      DeepImport::ModelsCache.add(self) # add to cache/set new import id

      # Track associations passed into constructor, track them
      belongs = DeepImport::Config.belongs_to(self.class)
      belongs.each do |other_name|
        other_instance = self.send(other_name)
        next unless other_instance
        DeepImport::ModelsCache.set_association_on(self, other_instance) 
      end
    end

    module HasMany

      def create(attributes = {})
        # TODO:
        # DeepImport.deep_import_safety_check("create", self, :build) { super(attributes) }
        if DeepImport.importing?
          if DeepImport.raise_error?
            raise "Blocked 'create' on #{proxy_association.owner.class}" 
          else
            # noop => build instead of create
            build(attributes)
          end
        else
          super(attributes)
        end
      end

      def create!(attributes = {})
        # TODO:
        # DeepImport.deep_import_safety_check("create!", self, :build) { super(attributes) }
        if DeepImport.importing?
          if DeepImport.raise_error?
            raise "Blocked 'create!' on #{proxy_association.owner.class}" 
          else
            # noop => build instead of create
            build(attributes)
          end
        else
          super(attributes)
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

    module BelongsTo

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
            if DeepImport.importing?
              raise "DeepImport: create_{model}(!) disabled"
              # pass on_save: :noop to ignore" 
              # TODO: provide ':on_belongs_to_create_other => :build_other' to DeepImport.import to override"
              # ^ redirect create to build (automatically or as option)
            else
              super
            end
          end
        end
      end
    end

    module Saveable
      def save
        DeepImport.deep_import_safety_check("save") { super }
      end

      def save!
        DeepImport.deep_import_safety_check("save!") { super }
      end

    end
  end

end

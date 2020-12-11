module DeepImport

  # Called from Railtie/boot in Rails
  # Otherwise: called by developer somewhere

  # TODO: consider removing this entirely

  def self.initialize!
    # TODO: add global config options for on_save: :noop

    config = DeepImport::Config.new
    if config.valid?
      # TODO: migrate this to calls in class def, remove need for config entirely
      Config.importable.each do |import_class|
        next unless import_class.respond_to? :setup_belongs_to_for_import
        import_class.setup_belongs_to_for_import(import_class)
      end
    else
      DeepImport.status = :error
    end

  end

end

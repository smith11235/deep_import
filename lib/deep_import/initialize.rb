module DeepImport

  # Called from Railtie/boot in Rails
  # Otherwise: called by developer somewhere

  # TODO: consider removing this entirely

  def self.initialize!
    # TODO: add global config options for on_save: :noop

    # TODO: remove need for this
    config = DeepImport::Config.new
    unless config.valid?
      DeepImport.status = :error
    end

  end

end

module DeepImport

  # Called from Railtie/boot in Rails
  # Otherwise: called by developer somewhere

  def self.initialize!
    if DeepImport.status != :uninitialized
      DeepImport.logger.warn "DeepImport already initialized - skipping initialize! call"
      return true 
    end
    DeepImport.logger.level = ENV["DEEP_IMPORT_LOG_LEVEL"] || "INFO" # verbose by default
    Initialize.new
    true
  end

  private 

  class Initialize

    def failure!(msg)
      DeepImport.logger.error "DeepImport: Initialize Failed: #{msg}".red
    end

    def initialize
      # otherwise the expectation is the :init status
      case false # failure case 
      when parse_config
        failure! "Parsing Config"
      when check_activerecord_import_gem
        failure! "ActiveRecord::Import unavailable"
      when modify_target_models
        failure! "Setting up models"
      when add_deep_import_models
        failure! "Unable to add deep import models"
      end
      DeepImport.mark_ready_for_import! 
    end

    def check_activerecord_import_gem
      DeepImport::Config.importable.each do |model_class|
        if ! model_class.respond_to? :import
          DeepImport.logger.error "#{model_class} does not respond_to? :import"
          DeepImport.logger.error "this method should exist from deep imports gem dependency on 'activerecord-import'"
          DeepImport.logger.error "Try adding: gem 'activerecord-import', :git => 'git://github.com/zdennis/activerecord-import.git' to your Gemfile"
          return false
        end
      end
      return true
    end

    # these things should only be done 1 time
    def parse_config
      config = DeepImport::Config.new
      if config.valid?
        true
      else
        DeepImport.status = :error
        false
      end
    end

    def modify_target_models
      DeepImport::Config.importable.each do |model_class| 
        model_class.class_eval { include DeepImport::ModelLogic }
      end
      true
    end

    def add_deep_import_models
      DeepImport::Config.importable.each do |model_class|
        deep_model_class = "DeepImport#{model_class}"
        Object.const_set(
          deep_model_class, 
          Class.new(ActiveRecord::Base)
        )
      end
      true
    end

  end

end

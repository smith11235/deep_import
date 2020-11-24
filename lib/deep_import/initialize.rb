module DeepImport
  # TODO: clean this up

  def self.initialize!( options = {} )
    reset = options.delete(:reset)
    if reset # || DeepImport.status == :error
      DeepImport.status = :init
      DeepImport.import_options = nil
    end
    # validate the import options
    DeepImport.import_options = options

    # check if deep import is already setup
    return true if DeepImport.ready_for_import?

    Initialize.new
  end

  private 

  class Initialize

    def failure!(msg)
      DeepImport.logger.error "DeepImport: Initialize Failed: #{msg}".red
    end

    def initialize
      # otherwise the expectation is the :init status
      raise "Calling DeepImport::Initialize when status != :init; status=#{DeepImport.status}" unless DeepImport.status == :init
      case false # failure case 
      when parse_config
        failure! "Parsing Config"
      when check_activerecord_import_gem
        failure! "ActiveRecord::Import unavailable"
      when modify_target_models
        failure! "Setting up models"
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

  end

end

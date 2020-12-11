module DeepImport
  module Saveable
    #def self.included(base) 
    #end

    def save(opts = {})
      if DeepImport.allow_commit?
        super(opts)
      else 
        true
      end
    end

    def save!(opts = {})
      if DeepImport.allow_commit?
        super(opts) 
      else
        true
      end
    end

  end
end

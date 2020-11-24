require 'spec_helper'

describe 'DeepImport.initialize!' do
  # executed through railtie
  # alternatively: DeepImport.initialize!
  # driven by: config/deep_import.yml

	it "should have Parent, Child, GrandChild as keys in DeepImport::Config.models" do
		DeepImport::Config.importable.should =~ [Parent,Child,GrandChild]
	end

	it "should add DeepImport::ModelLogic to Parent" do
		Parent.included_modules.should include( DeepImport::ModelLogic )
	end

	it "should add DeepImport::ModelLogic to Child" do
		Child.included_modules.should include( DeepImport::ModelLogic )
	end

	it "should add DeepImport::ModelLogic to GrandChild" do
		GrandChild.included_modules.should include( DeepImport::ModelLogic )
	end

  # TODO: move this to import_options, import
	it "should raise an error if called again with different options" do
    DeepImport.import do # sets initial options
    end
		expect { 
      DeepImport.import reset: false, on_save: :noop do
        # explicit global rules for safety/awareness - can override with reset_false
      end
    }.to raise_error
	end

end

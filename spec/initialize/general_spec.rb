require 'spec_helper'

describe 'DeepImport.initialize!' do

	it "should have [Parent, Child, GrandChild] as keys in DeepImport::Config.models" do
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

	it "should raise an error if called again with different options" do
    DeepImport.initialize! reset: true # ignore config/initializers/deep_import.rb 
		expect { 
      DeepImport.initialize! reset: false, on_save: :noop  # options are explicit global rules for safety/awareness
    }.to raise_error
	end

end

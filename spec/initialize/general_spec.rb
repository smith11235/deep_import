require 'spec_helper'

describe 'DeepImport.initialize! - General API' do
	before( :all ){ 
		ConfigHelper.new.valid_config
		DeepImport.initialize! 
	}
	
	it "should have [Parent, Child, GrandChild] as keys in DeepImport::Config.models" do
		DeepImport::Config.models.keys.should =~ [Parent,Child,GrandChild]
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
		expect { DeepImport.initialize! :on_save => :noop }.to raise_error
	end



end

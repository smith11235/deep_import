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

	describe DeepImport::ModelLogic do
		# this is tested from here as it needs the rest of what Initialize does
		# still figuring out the best way to show this
		it "should have methods disabled by default"
		it "should have methods enabled when DeepImport.ready_to_import?"

		describe "base enhancements" do
			it "should have deep_import_after_initialize"
			it "should have save_with_deep_import"
			it "should have save_without_deep_import"
			it "should have save_with_deep_import!"
			it "should have save_without_deep_import!"
		end


		describe "belongs to association methods" do
			it "should have build_parent_with_deep_import"
			it "should have build_parent_without_deep_import"
			it "should have create_parent_with_deep_import"
			it "should have create_parent_without_deep_import"
			it "should have create_parent_with_deep_import!"
			it "should have create_parent_without_deep_import!"
		end
	end


end

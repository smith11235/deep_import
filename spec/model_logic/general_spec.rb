require 'spec_helper'

describe 'DeepImport::ModelLogic - General API' do

	before(:all){
		ConfigHelper.new.valid_config
		DeepImport.initialize! 
	}

	it "should have teardown logic"

	describe Child do
		let( :child ){ Child.new }

		describe "base enhancements" do
			it "has accessible deep_import_id"	do
				Child.accessible_attributes.should include( :deep_import_id )
			end

			it "should have deep_import_after_initialize" do
				child.should be_respond_to :deep_import_after_initialize
			end

			it "should have save_with_deep_import" do
				child.should be_respond_to :save_with_deep_import
			end
			it "should have save_without_deep_import" do
				child.should be_respond_to :save_without_deep_import
			end
			it "should have save_with_deep_import!" do
				child.should be_respond_to :save_with_deep_import!
			end
			it "should have save_without_deep_import!" do
				child.should be_respond_to :save_without_deep_import!
			end
		end

		describe "belongs to association methods" do
			it "should have build_parent_with_deep_import" do
				child.should be_respond_to :build_parent_with_deep_import
			end
			it "should have build_parent_without_deep_import" do
				child.should be_respond_to :build_parent_without_deep_import
			end
			it "should have create_parent_with_deep_import" do
				child.should be_respond_to :create_parent_with_deep_import
			end
			it "should have create_parent_without_deep_import" do
				child.should be_respond_to :create_parent_without_deep_import
			end
			it "should have create_parent_with_deep_import!" do
				child.should be_respond_to :create_parent_with_deep_import!
			end
			it "should have create_parent_without_deep_import!" do
				child.should be_respond_to :create_parent_without_deep_import!
			end
		end
	end
end

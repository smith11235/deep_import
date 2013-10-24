require 'spec_helper'

describe 'DeepImport::Config - Missing API' do

	before( :all ) do
		DeepImport.logger ||= DeepImport.default_logger
		# remove the config
		ConfigHelper.new.remove_config
	end

	after( :all ) do
		# generate a good config
		ConfigHelper.new.valid_config 
	end

	describe "after instantiation" do
		let( :config ) { DeepImport::Config.new }

		it "should not be valid" do
			config.valid?.should == false
		end

		it "should not have any models in DeepImport::Config.models" do
			config.models.should be_empty	
		end

	end

end
